<template>
  <div class="field label-above">
    <label>Default units</label>
    <select
      v-model="descriptor.default_unit"
      class="normal-input">
      <option
        v-for="(label, key) in list"
        :key="key"
        :value="key">{{ key }}: {{ label }}
      </option>
    </select>
  </div>
</template>
<script>

import { Descriptor } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  computed: {
    validateFields () {
      return this.descriptor.name && this.descriptor.default_unit
    },

    descriptor: {
      get () {
        return this.modelValue
      },
      set () {
        this.$emit('update:modelValue', this.value)
      }
    }
  },

  data () {
    return {
      list: undefined
    }
  },

  created () {
    Descriptor.units().then(response => {
      this.list = response.body
    })
  }
}
</script>