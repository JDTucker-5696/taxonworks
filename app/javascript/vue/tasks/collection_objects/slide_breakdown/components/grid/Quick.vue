<template>
  <div class="position-absolute">
    <button
      @click="show = true"
      class="button normal-input button-default grid-button">#</button>
    <modal-component
      v-if="show"
      @close="show = false">
      <template #header>
        <h3>Quick grid</h3>
      </template>
      <template #body>
        <fieldset>
          <legend>Quick grid</legend>
          <div class="flex-separate middle">
            <div class="horizontal-left-content middle">
              <div class="margin-small-right">
                <label>Rows:</label>
                <input
                  class="grid-input"
                  v-model="rows"
                  type="number">
              </div>
              <div class="margin-small-right">
                <label>Columns:</label>
                <input
                  class="grid-input"
                  v-model="columns"
                  type="number"> 
              </div>
              <button
                class="button normal-input button-default"
                @click="createGrid">Set</button>
            </div>
            <div class="horizontal-left-content margin-medium-left">
              <button
                class="button normal-input button-default margin-small-right"
                @click="setGrid(10, 2)">10x2</button>
              <button
                class="button normal-input button-default margin-small-right"
                @click="setGrid(10, 3)">10x3</button>
              <button 
                class="button normal-input button-default"
                @click="setGrid(1, 1)">1x1</button>
            </div>
          </div>
        </fieldset>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'

export default {
  components: { ModalComponent },

  props: {
    height: {
      type: Number,
      required: true
    },
    width: {
      type: Number,
      required: true
    }
  },

  emits: ['grid'],

  data () {
    return {
      rows: 1,
      columns: 1,
      show: false
    }
  },

  methods: {
    createGrid () {
      const wSize = this.width / this.columns
      const hSize = this.height / this.rows
      const vlines = this.segments(wSize, this.columns)
      const hlines = this.segments(hSize, this.rows)

      this.$emit('grid', { vlines, hlines })
    },

    segments (size, parts) {
      const segments = []

      for (let i = 0; i <= parts; i++) {
        segments.push(size * i)
      }
      return segments
    },

    setGrid (rows, columns) {
      this.columns = columns
      this.rows = rows
      this.createGrid()
    }
  }
}
</script>

<style lang="scss" scoped>
  :deep(.modal-container) {
    width: 500px
  }
  .grid-button {
    top: 10px;
    width: 22px;
    height: 22px;
    text-align: center;
  }
  .grid-input {
    width: 50px;
  }
</style>
