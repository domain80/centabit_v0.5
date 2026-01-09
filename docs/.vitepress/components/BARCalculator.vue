<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const totalBudget = ref(1500)
const totalDays = ref(30)
const currentDay = ref(15)
const actualSpent = ref(800)
const frontLoadFactor = ref(1.3)

// Front-loaded curve calculation
const frontLoadedCurve = (t, factor) => {
  const a = factor
  return Math.min(a * t - (a - 1) * Math.pow(t, 2), 1)
}

// Calculate BAR
const bar = computed(() => {
  const t = currentDay.value / totalDays.value
  const expectedCurve = frontLoadedCurve(t, frontLoadFactor.value)
  const expectedSpent = expectedCurve * totalBudget.value
  return actualSpent.value / Math.max(expectedSpent, 0.01)
})

const expectedSpent = computed(() => {
  const t = currentDay.value / totalDays.value
  const expectedCurve = frontLoadedCurve(t, frontLoadFactor.value)
  return expectedCurve * totalBudget.value
})

const remaining = computed(() => totalBudget.value - actualSpent.value)

// BAR status
const barStatus = computed(() => {
  const b = bar.value
  if (b < 0.8) return { level: 'excellent', color: 'green', message: 'Spending slower than planned (good!)' }
  if (b < 1.0) return { level: 'good', color: 'green', message: 'Under budget - good pace' }
  if (b === 1.0) return { level: 'perfect', color: 'blue', message: 'Perfect pace' }
  if (b < 1.2) return { level: 'warning', color: 'yellow', message: 'Overspending - may run out early' }
  if (b < 1.5) return { level: 'critical', color: 'orange', message: 'Significantly over budget' }
  return { level: 'danger', color: 'red', message: 'Severely over budget!' }
})

const frontLoadLabel = computed(() => {
  const f = frontLoadFactor.value
  if (f === 1.0) return 'Linear'
  if (f < 1.0) return 'Back-loaded'
  if (f < 1.2) return 'Slight front-load'
  if (f < 1.4) return 'Moderate front-load'
  return 'Heavy front-load'
})

// Chart data
const chartData = computed(() => {
  const canvas = chartCanvas.value
  if (!canvas) return null

  const ctx = canvas.getContext('2d')
  const width = canvas.width
  const height = canvas.height

  return {
    ctx,
    width,
    height,
    points: Array.from({ length: totalDays.value + 1 }, (_, day) => {
      const t = day / totalDays.value
      const frontLoaded = frontLoadedCurve(t, frontLoadFactor.value) * totalBudget.value
      const linear = (day / totalDays.value) * totalBudget.value

      return {
        day,
        expected: frontLoaded,
        linear,
        actual: day === currentDay.value ? actualSpent.value : null,
      }
    })
  }
})

const chartCanvas = ref(null)

// Draw chart
const drawChart = () => {
  if (!chartData.value) return

  const { ctx, width, height, points } = chartData.value
  const padding = 50
  const plotWidth = width - padding * 2
  const plotHeight = height - padding * 2

  // Clear canvas
  ctx.clearRect(0, 0, width, height)

  // Set colors based on theme
  const isDark = document.documentElement.classList.contains('dark')
  const gridColor = isDark ? '#374151' : '#e5e7eb'
  const textColor = isDark ? '#9ca3af' : '#6b7280'
  const linearColor = isDark ? '#6b7280' : '#9ca3af'
  const expectedColor = '#10b981'
  const actualColor = '#ef4444'

  // Draw grid
  ctx.strokeStyle = gridColor
  ctx.lineWidth = 1
  for (let i = 0; i <= 5; i++) {
    const y = padding + (plotHeight / 5) * i
    ctx.beginPath()
    ctx.moveTo(padding, y)
    ctx.lineTo(width - padding, y)
    ctx.stroke()
  }

  // Scale functions
  const xScale = (day) => padding + (day / totalDays.value) * plotWidth
  const yScale = (value) => height - padding - (value / totalBudget.value) * plotHeight

  // Draw linear curve (dashed)
  ctx.strokeStyle = linearColor
  ctx.setLineDash([5, 5])
  ctx.lineWidth = 1
  ctx.beginPath()
  points.forEach((point, i) => {
    const x = xScale(point.day)
    const y = yScale(point.linear)
    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  })
  ctx.stroke()

  // Draw expected curve (solid green)
  ctx.strokeStyle = expectedColor
  ctx.setLineDash([])
  ctx.lineWidth = 3
  ctx.beginPath()
  points.forEach((point, i) => {
    const x = xScale(point.day)
    const y = yScale(point.expected)
    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  })
  ctx.stroke()

  // Draw current day line
  ctx.strokeStyle = textColor
  ctx.setLineDash([3, 3])
  ctx.lineWidth = 1
  ctx.beginPath()
  const currentX = xScale(currentDay.value)
  ctx.moveTo(currentX, padding)
  ctx.lineTo(currentX, height - padding)
  ctx.stroke()

  // Draw actual spending point
  ctx.fillStyle = actualColor
  ctx.strokeStyle = actualColor
  ctx.setLineDash([])
  ctx.lineWidth = 4
  const actualX = xScale(currentDay.value)
  const actualY = yScale(actualSpent.value)
  ctx.beginPath()
  ctx.arc(actualX, actualY, 6, 0, 2 * Math.PI)
  ctx.fill()

  // Draw axes
  ctx.strokeStyle = textColor
  ctx.lineWidth = 2
  ctx.setLineDash([])
  ctx.beginPath()
  ctx.moveTo(padding, padding)
  ctx.lineTo(padding, height - padding)
  ctx.lineTo(width - padding, height - padding)
  ctx.stroke()

  // Draw labels
  ctx.fillStyle = textColor
  ctx.font = '12px sans-serif'
  ctx.textAlign = 'center'
  ctx.fillText('Days', width / 2, height - 10)

  ctx.save()
  ctx.translate(15, height / 2)
  ctx.rotate(-Math.PI / 2)
  ctx.fillText('Amount ($)', 0, 0)
  ctx.restore()

  // Draw legend
  const legendY = padding + 20
  const legendItems = [
    { color: linearColor, label: 'Linear (naive)', dashed: true },
    { color: expectedColor, label: 'Front-loaded curve', dashed: false },
    { color: actualColor, label: 'Your actual spending', dashed: false },
  ]

  let legendX = width - padding - 200
  ctx.textAlign = 'left'
  legendItems.forEach((item, i) => {
    const y = legendY + i * 20
    ctx.strokeStyle = item.color
    ctx.fillStyle = item.color
    ctx.setLineDash(item.dashed ? [5, 5] : [])
    ctx.lineWidth = item.label.includes('actual') ? 4 : 2
    ctx.beginPath()
    ctx.moveTo(legendX, y)
    ctx.lineTo(legendX + 30, y)
    ctx.stroke()

    ctx.fillText(item.label, legendX + 40, y + 4)
  })
}

onMounted(() => {
  drawChart()
})

watch([totalBudget, totalDays, currentDay, actualSpent, frontLoadFactor], () => {
  drawChart()
})

// Watch for theme changes
onMounted(() => {
  const observer = new MutationObserver(() => {
    drawChart()
  })
  observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
})
</script>

<template>
  <div class="bar-calculator">
    <!-- Header -->
    <div class="header">
      <h1>Budget Adherence Ratio (BAR) Calculator</h1>
      <p>Track if you're on pace with your spending</p>
    </div>

    <!-- BAR Score Display -->
    <div :class="['bar-score', `bar-${barStatus.color}`]">
      <div class="bar-score-main">
        <div class="bar-value">
          <div class="bar-label">Current BAR</div>
          <div class="bar-number">{{ bar.toFixed(2) }}</div>
        </div>
        <div class="bar-status">
          <div class="bar-label">Status</div>
          <div class="bar-message">{{ barStatus.message }}</div>
        </div>
      </div>

      <div class="bar-metrics">
        <div class="metric">
          <div class="metric-label">Expected to Spend</div>
          <div class="metric-value">${{ expectedSpent.toFixed(2) }}</div>
        </div>
        <div class="metric">
          <div class="metric-label">Actually Spent</div>
          <div class="metric-value">${{ actualSpent.toFixed(2) }}</div>
        </div>
        <div class="metric">
          <div class="metric-label">Remaining</div>
          <div class="metric-value">${{ remaining.toFixed(2) }}</div>
        </div>
      </div>
    </div>

    <!-- BAR Interpretation Guide -->
    <div class="interpretation-guide">
      <h3>BAR Interpretation Guide</h3>
      <div class="guide-grid">
        <div class="guide-item guide-green">
          <span class="guide-range">BAR &lt; 0.8</span>
          <span class="guide-text">Excellent - spending much slower than planned</span>
        </div>
        <div class="guide-item guide-green">
          <span class="guide-range">BAR 0.8-1.0</span>
          <span class="guide-text">Good - under budget, healthy pace</span>
        </div>
        <div class="guide-item guide-blue">
          <span class="guide-range">BAR = 1.0</span>
          <span class="guide-text">Perfect pace - right on track</span>
        </div>
        <div class="guide-item guide-yellow">
          <span class="guide-range">BAR 1.0-1.2</span>
          <span class="guide-text">Warning - overspending, watch carefully</span>
        </div>
        <div class="guide-item guide-orange">
          <span class="guide-range">BAR 1.2-1.5</span>
          <span class="guide-text">Critical - significantly over budget</span>
        </div>
        <div class="guide-item guide-red">
          <span class="guide-range">BAR &gt; 1.5</span>
          <span class="guide-text">Danger - severe overspending, immediate action needed</span>
        </div>
      </div>

      <div class="key-rule">
        <strong>Key Rule:</strong> Stay below 1.0 to ensure you don't run out of budget before the period ends.
      </div>
    </div>

    <!-- Controls and Chart -->
    <div class="calculator-grid">
      <!-- Controls -->
      <div class="controls">
        <h3>Adjust Parameters</h3>

        <div class="control">
          <label>Total Budget: ${{ totalBudget }}</label>
          <input type="range" min="500" max="5000" step="100" v-model.number="totalBudget" />
        </div>

        <div class="control">
          <label>Budget Period: {{ totalDays }} days</label>
          <input type="range" min="7" max="90" step="1" v-model.number="totalDays" />
        </div>

        <div class="control">
          <label>Current Day: {{ currentDay }} of {{ totalDays }}</label>
          <input type="range" min="0" :max="totalDays" step="1" v-model.number="currentDay" />
        </div>

        <div class="control">
          <label>Actual Spent: ${{ actualSpent }}</label>
          <input type="range" min="0" :max="totalBudget" step="10" v-model.number="actualSpent" />
        </div>

        <div class="control control-advanced">
          <label>
            Front-load Factor: {{ frontLoadFactor.toFixed(2) }}
            <span class="factor-label">{{ frontLoadLabel }}</span>
          </label>
          <input type="range" min="0.8" max="2.0" step="0.1" v-model.number="frontLoadFactor" />
          <div class="control-hint">
            Adjust how aggressively the curve expects early spending. 1.0 = linear, &gt;1.0 = front-loaded (payday effect), &lt;1.0 = back-loaded (savers)
          </div>
        </div>
      </div>

      <!-- Chart -->
      <div class="chart">
        <h3>Spending Curve Visualization</h3>
        <canvas ref="chartCanvas" width="600" height="400"></canvas>
      </div>
    </div>
  </div>
</template>

<style scoped>
.bar-calculator {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}

.header {
  text-align: center;
  margin-bottom: 2rem;
}

.header h1 {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
  border: none;
}

.header p {
  color: var(--vp-c-text-2);
}

.bar-score {
  border: 2px solid;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.bar-green { background-color: var(--vp-c-green-soft); border-color: var(--vp-c-green-1); }
.bar-blue { background-color: var(--vp-c-blue-soft); border-color: var(--vp-c-blue-1); }
.bar-yellow { background-color: var(--vp-c-yellow-soft); border-color: var(--vp-c-yellow-1); }
.bar-orange { background-color: var(--vp-custom-block-warning-bg); border-color: var(--vp-custom-block-warning-border); }
.bar-red { background-color: var(--vp-c-danger-soft); border-color: var(--vp-c-danger-1); }

.bar-score-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  gap: 2rem;
}

.bar-value, .bar-status {
  flex: 1;
}

.bar-label {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
  margin-bottom: 0.25rem;
}

.bar-number {
  font-size: 2.5rem;
  font-weight: bold;
  color: var(--vp-c-text-1);
}

.bar-message {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.bar-metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.metric {
  text-align: center;
}

.metric-label {
  font-size: 0.875rem;
  color: var(--vp-c-text-2);
  margin-bottom: 0.25rem;
}

.metric-value {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.interpretation-guide {
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.interpretation-guide h3 {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 1rem;
  border: none;
}

.guide-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 0.75rem;
  font-size: 0.875rem;
}

.guide-item {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
}

.guide-range {
  font-family: var(--vp-font-family-mono);
  font-weight: 600;
  min-width: 6rem;
  flex-shrink: 0;
}

.guide-text {
  color: var(--vp-c-text-2);
}

.guide-green .guide-range { color: var(--vp-c-green-1); }
.guide-blue .guide-range { color: var(--vp-c-blue-1); }
.guide-yellow .guide-range { color: var(--vp-c-yellow-1); }
.guide-orange .guide-range { color: #f97316; }
.guide-red .guide-range { color: var(--vp-c-danger-1); }

.key-rule {
  margin-top: 1rem;
  padding: 0.75rem;
  background-color: var(--vp-c-blue-soft);
  border: 1px solid var(--vp-c-blue-2);
  border-radius: 6px;
  font-size: 0.875rem;
  color: var(--vp-c-text-1);
}

.calculator-grid {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 2rem;
  margin-bottom: 2rem;
}

@media (max-width: 768px) {
  .calculator-grid {
    grid-template-columns: 1fr;
  }

  .bar-score-main {
    flex-direction: column;
    gap: 1rem;
  }

  .bar-metrics {
    grid-template-columns: 1fr;
  }
}

.controls, .chart {
  background-color: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 1.5rem;
}

.controls h3, .chart h3 {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 1rem;
  border: none;
}

.control {
  margin-bottom: 1.5rem;
}

.control label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
  color: var(--vp-c-text-1);
}

.control input[type="range"] {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: var(--vp-c-divider);
  outline: none;
  -webkit-appearance: none;
}

.control input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--vp-c-brand-1);
  cursor: pointer;
}

.control input[type="range"]::-moz-range-thumb {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--vp-c-brand-1);
  cursor: pointer;
  border: none;
}

.control-advanced {
  padding-top: 1rem;
  border-top: 1px solid var(--vp-c-divider);
}

.factor-label {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  margin-left: 0.5rem;
}

.control-hint {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  margin-top: 0.5rem;
  line-height: 1.4;
}

.chart canvas {
  width: 100%;
  height: auto;
  display: block;
  margin-top: 1rem;
}
</style>
