// A real pointer must reach an input on its first click while label help is open.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const apps=['two_proportions','two_means','power_explorer','dropout_adjustment','prevalence_precision','sampling_distributions'];
async function checkVisibleHelp(page,frame,label){
 await frame.locator('.input-question').evaluateAll(items=>items.forEach(el=>{
  for(let parent=el.parentElement;parent;parent=parent.parentElement)if(parent.tagName==='DETAILS')parent.open=true;
 }));
 const buttons=await frame.locator('.input-question:visible').all();
 let tested=0;
 for(const button of buttons){
  const fieldId=(await button.getAttribute('id')).replace(/-question$/,'');
  const editableId=await frame.evaluate(id=>{
   const field=document.getElementById(id),container=field.closest('.shiny-input-container');
   const candidates=[document.getElementById(id+'-number'),field,...(container?.querySelectorAll('input,textarea,select')||[])];
   return candidates.find(el=>el&&el.checkVisibility({checkOpacity:true})&&!el.disabled&&el.type!=='hidden'&&el.getBoundingClientRect().height>5)?.id;
  },fieldId);
  if(!editableId)continue;
  const field=frame.locator('[id="'+editableId+'"]');
  await button.evaluate(el=>el.scrollIntoView({block:'start'}));
  await button.scrollIntoViewIfNeeded();
  await page.waitForTimeout(200);
  await page.mouse.move(1,1);
  await button.hover();
  const tip=frame.locator('.input-guidance-popover:not([hidden])');
  await tip.waitFor().catch(async error=>{
   console.error(label,fieldId,await button.boundingBox());
   await page.screenshot({path:'build/help-input-failure.png'});throw error;
  });
  const geometry=await frame.evaluate(id=>{
   const input=document.getElementById(id),tip=document.querySelector('.input-guidance-popover:not([hidden])');
   const a=input.getBoundingClientRect(),b=tip.getBoundingClientRect();
   return {overlap:a.left<b.right&&a.right>b.left&&a.top<b.bottom&&a.bottom>b.top,
    visible:b.height>20&&b.top>=0&&b.bottom<=innerHeight+1};
  },editableId);
  assert(!geometry.overlap,label+': help covers '+editableId);
  assert(geometry.visible,label+': help fits viewport for '+editableId);
  // No locator click: its automatic scrolling could hide the original bug.
  const box=await field.boundingBox();
  await page.mouse.click(box.x+box.width/2,box.y+box.height/2);
  assert(await field.evaluate(el=>document.activeElement===el),label+': first click reaches '+editableId);
  assert.equal(await frame.locator('.input-guidance-popover:not([hidden])').count(),0);
  await page.keyboard.press('Escape');
  tested++;
 }
 assert(tested>0,label+': at least one editable control checked');
 console.log(label+': '+tested+' help/input pairs passed');
}
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  for(const app of apps){
   if(process.argv[3]&&process.argv[3]!==app)continue;
   const context=await browser.newContext({viewport:{width:1400,height:1000}}),page=await context.newPage();
   await page.goto(base+'/'+app+'/');
   let frame;
   for(let i=0;i<180&&!frame;i++){
    for(const candidate of page.frames())if(await candidate.locator('.input-question').count())frame=candidate;
    if(!frame)await page.waitForTimeout(1000);
   }
   assert(frame,app+' loads');
   await frame.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1&&!document.documentElement.classList.contains('shiny-busy'));
   await frame.waitForFunction(()=>[...document.querySelectorAll('input.js-range-slider')].every(el=>document.getElementById(el.id+'-number')));
   for(const width of [1400,390]){
    await page.setViewportSize({width,height:1000});
    await frame.getByRole('tab',{name:'Overview',exact:true}).click();
    await checkVisibleHelp(page,frame,app+' '+width);
   }
   await frame.getByRole('tab',{name:'Report',exact:true}).click();
   if(await frame.locator('.input-question:visible').count())await checkVisibleHelp(page,frame,app+' report');
   await context.close();
  }
  const page=await browser.newPage({viewport:{width:390,height:844}});
  for(const path of ['design_questionnaire/','quiz/','student-materials/flashcards/cards.html','assumptions_report/']){
   await page.goto(base+'/'+path);
   await page.locator('.input-question').first().waitFor();
   if(path==='assumptions_report/')await page.locator('details.plan-section').first().evaluate(el=>el.open=true);
   await checkVisibleHelp(page,page,path);
  }
  console.log('All shared app help permits direct input, including narrow layouts and report answers.');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exit(1);});
