const form       = document.getElementById('search-form');
const input      = document.getElementById('search-input');
const trendsList = document.getElementById('trends-list');

form.addEventListener('submit', e => {
  e.preventDefault();
  const q = input.value.trim();
  if (!q) return;

  fetch('/searches', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query: q })
  })
  .then(() => {
    input.value = '';
    loadTrends();
  })
  .catch(err => console.error('Search POST failed:', err));
});

function loadTrends() {
  fetch('/analytics/trends')
    .then(r => r.json())
    .then(data => {
      trendsList.innerHTML = '';
      Object.entries(data).forEach(([term, stats]) => {
        const li = document.createElement('li');
        li.textContent = term;

        const cnt = document.createElement('span');
        cnt.className = 'count';
        cnt.textContent = `(${stats.total})`;

        const pct = document.createElement('span');
        pct.className = 'percent';
        pct.textContent = `(${stats.pct}%)`;

        li.append(cnt, pct);
        trendsList.appendChild(li);
      });
    })
    .catch(err => console.error('Failed to load trends:', err));
}

loadTrends();
setInterval(loadTrends, 30_000);
