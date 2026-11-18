/* Preserve shared activity URLs after moving activities into the tutorial. MIT. */
(() => {
  const site = new URL('../', location.href);
  const requested = new URL(location.href);
  const activity = requested.searchParams.get('activity');
  async function redirect() {
    const response = await fetch(new URL('activity-routes.json', site));
    if (!response.ok) throw new Error('Activity routes unavailable');
    const routes = await response.json();
    const target = new URL(Object.hasOwn(routes, activity) ? routes[activity] : 'book/', site);
    // Saved app state and explicit writing stages belong on the dedicated app.
    if (requested.hash || requested.searchParams.has('stage')) {
      const casesResponse = await fetch(new URL('teaching-cases.json', site));
      if (!casesResponse.ok) throw new Error('Activity settings unavailable');
      const cases = await casesResponse.json();
      if (Object.hasOwn(cases, activity)) {
        target.href = new URL(cases[activity].app + '/', site).href;
        target.search = requested.search;
        target.hash = requested.hash;
      }
    }
    document.getElementById('continue').href = target.href;
    location.replace(target);
  }
  redirect().catch(() => {
    document.getElementById('status').textContent = 'Open the tutorial and select an activity preview to use the app within the lesson.';
  });
})();
