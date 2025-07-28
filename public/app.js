const form        = document.getElementById('search-form');
const input       = document.getElementById('search-input');
const trendsList  = document.getElementById('trends-list');
const loader      = document.getElementById('loader');
const emptyState  = document.getElementById('empty');
const suggestions = document.getElementById('suggestions');
const themeToggle = document.getElementById('theme-toggle');

let trendsChart    = null;
let popularTerms   = [];
let typeaheadTimer = null;
let logTimer       = null;

function applyTheme(isDark) {
  document.body.classList.toggle('dark', isDark);
  localStorage.setItem('darkMode', isDark);
}
applyTheme(localStorage.getItem('darkMode') === 'true');
themeToggle.addEventListener('click', () => {
  applyTheme(!document.body.classList.contains('dark'));
});

function submitSearch(q) {
  fetch('/searches', {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ query: q })
  })
  .then(() => {
    loadTrends();
  })
  .catch(console.error);
}

input.addEventListener('input', () => {
  clearTimeout(typeaheadTimer);
  clearTimeout(logTimer);

  const raw = input.value.trim();
  const q   = raw.toLowerCase();

  if (q) {
    typeaheadTimer = setTimeout(() => {
      const matches = popularTerms.filter(term =>
        term.toLowerCase().startsWith(q)
      );

      suggestions.innerHTML = '';
      if (matches.length) {
        matches.forEach(item => {
          const li = document.createElement('li');
          li.textContent = item;
          li.addEventListener('click', () => {
            suggestions.classList.add('hidden');
            input.value = item;
            submitSearch(item);
          });
          suggestions.appendChild(li);
        });
        suggestions.classList.remove('hidden');
      } else {
        suggestions.classList.add('hidden');
      }
    }, 150);
  } else {
    suggestions.classList.add('hidden');
  }

  if (raw) {
    logTimer = setTimeout(() => {
      submitSearch(raw);
    }, 750);
  }
});

input.addEventListener('blur', () => {
  setTimeout(() => suggestions.classList.add('hidden'), 200);
});

form.addEventListener('submit', e => {
  e.preventDefault();
  clearTimeout(logTimer);
  suggestions.classList.add('hidden');
  const q = input.value.trim();
  if (!q) return;
  input.value = '';
  submitSearch(q);
});

function loadTrends() {
  loader.classList.remove('hidden');
  trendsList.classList.add('hidden');
  emptyState.classList.add('hidden');

  fetch('/analytics/trends')
    .then(res => res.json())
    .then(data => {
      loader.classList.add('hidden');
      popularTerms = Object.keys(data);
      if (popularTerms.length === 0) {
        emptyState.classList.remove('hidden');
        return;
      }

      trendsList.innerHTML = '';
      popularTerms.forEach(term => {
        const stats = data[term];
        const li = document.createElement('li');
        li.innerHTML = `
          <span class="label">${term}</span>
          <span class="stats">
            <span class="count">(${stats.total})</span>
            <span class="percent">(${stats.pct}%)</span>
          </span>`;
        trendsList.appendChild(li);
      });
      trendsList.classList.remove('hidden');

      const labels = popularTerms;
      const counts = labels.map(t => data[t].total);

      if (trendsChart) trendsChart.destroy();
      const ctx = document.getElementById('trends-chart').getContext('2d');
      trendsChart = new Chart(ctx, {
        type: 'bar',
        data: {
          labels,
          datasets: [{
            label: 'Search Count',
            data: counts,
            backgroundColor: 'rgba(41,128,185,0.6)',
            borderColor:   'rgba(41,128,185,1)',
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          scales: {
            x: { ticks: { autoSkip: false } },
            y: { beginAtZero: true }
          },
          plugins: { legend: { display: false } }
        }
      });
    })
    .catch(err => {
      console.error('Error loading trends:', err);
      loader.classList.add('hidden');
      emptyState.textContent = 'Failed to load data.';
      emptyState.classList.remove('hidden');
    });
}

loadTrends();
setInterval(loadTrends, 30_000);
