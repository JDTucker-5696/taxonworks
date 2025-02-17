<template>
  <div class="vue-otu-picker">
    <div class="horizontal-left-content">
      <autocomplete
        url="/sequences/autocomplete"
        class="separate-right"
        label="label_html"
        min="2"
        display="label"
        @getItem="emitSequence"
        @getInput="callbackInput"
        @found="found = $event"
        :clear-after="clearAfter"
        placeholder="Select a sequence"
        param="term"/>
      <button
        v-if="!found"
        class="button normal-input button-default"
        type="button"
        @click="create = true">
        New
      </button>
    </div>
    <modal-component
      v-if="create"
      @close="create = false">
      <template #header>
        <h3>Create sequence</h3>
      </template>
      <template #body>
        <div>
          <label>Name</label>
          <input 
            class="separate-bottom"
            type="text"
            v-model="sequence.name">
          <label>Sequence</label>
          <textarea
            class="separate-bottom"
            v-model="sequence.sequence"
            rows="5"/>
          <ul class="no_bullets">
            <li
              v-for="item in sequenceTypes"
              :key="item">
              <label>
                <input
                  type="radio"
                  :value="item"
                  v-model="sequence.sequence_type">
                {{ item }}
              </label>
            </li>
          </ul>
        </div>
      </template>
      <template #footer>
        <button
          class="button normal-input button-submit"
          type="button"
          :disabled="!validateFields"
          @click="createSequence">
          Create
        </button>
      </template>
    </modal-component>
  </div>
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import ModalComponent from 'components/ui/Modal.vue'
import AjaxCall from 'helpers/ajaxCall'

import { CreateSequence } from '../request/resources'

export default {
  components: {
    Autocomplete,
    ModalComponent
  },

  props: {
    clearAfter: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'getInput',
    'getItem'
  ],

  computed: {
    validateFields () {
      return this.sequence.name && this.sequence.sequence && this.sequence.sequence_type
    }
  },

  data () {
    return {
      found: true,
      create: false,
      type: undefined,
      sequenceTypes: ['AA', 'DNA', 'RNA'],
      sequence: {
        name: undefined,
        sequence: undefined,
        sequence_type: undefined
      }
    }
  },

  watch: {
    type (newVal, oldVal) {
      if (newVal != oldVal) {
        this.resetPicker()
        this.sequence.name = newVal
        this.found = true
        this.$emit('getInput', newVal)
      }
    }
  },

  methods: {
    resetPicker () {
      this.sequence = {
        name: undefined,
        sequence: undefined,
        sequence_type: undefined
      }
      this.create = false
    },

    createSequence () {
      CreateSequence(this.sequence).then(response => {
        this.$emit('getItem', response.body)
        this.create = false
        this.found = true
      })
    },

    emitSequence (sequence) {
      AjaxCall('get', `/sequences/${sequence.id}.json`).then(response => {
        this.$emit('getItem', response.body)
      })
    },

    callbackInput (event) {
      this.type = event
      this.$emit('getInput', event)
    }
  }
}
</script>