(() => {
  const hud = document.getElementById('hud');
  const elAuthority = document.getElementById('authority');
  const elHeat = document.getElementById('heat');
  const elPath = document.getElementById('path');

  let visible = false;

  function toggle() {
    visible = !visible;
    if (visible) hud.classList.remove('hidden');
    else hud.classList.add('hidden');
  }

  function update(meta) {
    if (!meta) return;
    if (typeof meta.authority === 'number') elAuthority.textContent = meta.authority;
    if (typeof meta.heat === 'number') elHeat.textContent = meta.heat;
    if (typeof meta.path === 'string') elPath.textContent = meta.path;
  }

  window.addEventListener('message', (e) => {
    const data = e.data || {};
    if (data.type === 'authority:toggle') {
      toggle();
      return;
    }
    if (data.type === 'authority:update') {
      update(data.data);
      return;
    }
  });
})();


