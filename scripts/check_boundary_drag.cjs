// Exercise the actual exported WebR app: gestures, shared R results and resets.
const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  fs.mkdirSync('build/boundary-drag',{recursive:true});
  const page=await browser.newPage({viewport:{width:1600,height:1100}});
  await page.goto(base+'/study/?activity=alpha_beta');
  let frame;
  for(let i=0;i<150;i++){
   for(const candidate of page.frames()) if(await candidate.locator('#boundary-controls').count()) frame=candidate;
   if(frame) break;
   await page.waitForTimeout(1000);
  }
  assert(frame,'Sampling app loaded');
  await frame.waitForFunction(()=>document.querySelectorAll('.boundary-handle').length===2);
  const alpha=()=>frame.locator('#boundary-controls').getAttribute('data-alpha').then(Number);
  const power=()=>frame.locator('#boundary-controls').getAttribute('data-power').then(Number);
  const settled=async()=>{
   await frame.waitForFunction(()=>{
    const plot=document.querySelector('#distributions'), metrics=document.querySelector('#overview_metrics');
    const current=(Math.round(Number(document.querySelector('#boundary-controls').dataset.power)*1000)/10)+'%';
    return !plot.classList.contains('recalculating') && !metrics.classList.contains('recalculating') &&
      plot.querySelector('img')?.complete && metrics.querySelector('.app-value')?.textContent===current;
   });
   // The image and its measured coordinates arrive in separate Shiny messages.
   await page.waitForTimeout(250);
  };
  const handle=(side='upper',panel=0)=>frame.locator(`.boundary-handle[data-side="${side}"][data-panel="${panel}"]`);
  const reset=async()=>{
   const settings=frame.locator('.app-settings');
   if(await settings.count() && !await settings.evaluate(e=>e.open)) await settings.locator(':scope > summary').click();
   await frame.locator('#load_case').click();
   await frame.waitForFunction(()=>Math.abs(Number(document.querySelector('#boundary-controls').dataset.alpha)-.05)<1e-10 && document.querySelectorAll('.boundary-handle').length===2);
   await settled();
  };
  const drag=async(locator,dx)=>{
   await settled();
   await locator.locator('.boundary-grip').scrollIntoViewIfNeeded();
   const box=await locator.locator('.boundary-grip').boundingBox();
   await page.mouse.move(box.x+box.width/2,box.y+box.height/2);
   await page.mouse.down();await page.mouse.move(box.x+box.width/2+dx,box.y+box.height/2,{steps:12});
   await page.mouse.up();
  };
  assert(Math.abs(await power()-.508701453763092)<1e-9);
  await drag(handle(),-35);
  await frame.waitForFunction(()=>Number(document.querySelector('#boundary-controls').dataset.alpha)>.05);
  await settled();
  assert(await power()>.5087,'Moving the upper boundary left increases power');
  await handle().press('End');
  await frame.waitForFunction(()=>Math.abs(Number(document.querySelector('#boundary-controls').dataset.alpha)-.001)<1e-10);
  await handle().press('Home');
  await frame.waitForFunction(()=>Math.abs(Number(document.querySelector('#boundary-controls').dataset.alpha)-.20)<1e-10);
  await frame.locator('a[data-value="Report"]').click();
  await frame.locator('#report_preview').filter({hasText:'Type I error probability: 20%'}).waitFor();
  console.log('Mouse, keyboard limits and current report passed.');
  await frame.locator('a[data-value="Overview"]').click();
  await reset();
  await drag(handle('upper',1),30);
  await frame.waitForFunction(()=>Number(document.querySelector('#boundary-controls').dataset.alpha)<.05);
  await reset();
  await frame.evaluate(()=>document.getElementById('sidedness').selectize.setValue('two.sided'));
  await frame.waitForFunction(()=>document.querySelectorAll('.boundary-handle').length===4);
  await drag(handle('lower'),25);
  await frame.waitForFunction(()=>Number(document.querySelector('#boundary-controls').dataset.alpha)>.05);
  const lower=Number(await handle('lower').getAttribute('aria-valuenow'));
  const upper=Number(await handle('upper').getAttribute('aria-valuenow'));
  assert(Math.abs(lower+upper-240)<1e-9,'Equal-tail boundaries stay symmetric');
  assert.equal(await handle('lower',0).getAttribute('aria-valuenow'),await handle('lower',1).getAttribute('aria-valuenow'));
  console.log('Both panels and two-sided symmetry passed.');
  await settled();
  await page.screenshot({path:'build/boundary-drag/two-sided.png'});
  await frame.evaluate(()=>document.getElementById('sidedness').selectize.setValue('less'));
  await frame.waitForFunction(()=>document.querySelectorAll('.boundary-handle').length===2 && document.querySelector('.boundary-handle').dataset.side==='lower');
  await handle('lower').press('End');
  await frame.waitForFunction(()=>Math.abs(Number(document.querySelector('#boundary-controls').dataset.alpha)-.20)<1e-10);
  await reset();
  await page.setViewportSize({width:720,height:1100});
  await frame.locator('#distributions').scrollIntoViewIfNeeded();
  await page.waitForTimeout(1200);
  const box=await handle().locator('.boundary-grip').boundingBox();
  const cdp=await page.context().newCDPSession(page);
  await cdp.send('Emulation.setTouchEmulationEnabled',{enabled:true});
  const touch=(x)=>[{x,y:box.y+box.height/2}];
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:touch(box.x+box.width/2)});
  await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:touch(box.x+box.width/2-25)});
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await frame.waitForFunction(()=>Number(document.querySelector('#boundary-controls').dataset.alpha)>.05);
  await settled();
  assert(Number.isFinite(await alpha()));
  await page.screenshot({path:'build/boundary-drag/touch.png'});
  const axe=process.env.AXE_PATH||require.resolve('axe-core/axe.min.js');
  await frame.addScriptTag({path:axe});
  const violations=await frame.evaluate(async()=>(await axe.run('.boundary-explorer')).violations);
  assert.deepEqual(violations,[],'Boundary controls pass accessibility checks');
  await reset();
  console.log('Boundary interaction passed: both panels, greater/less/two-sided tests, symmetry, mouse, touch after resize, keyboard limits, current report, reset and accessibility.');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exit(1)});
