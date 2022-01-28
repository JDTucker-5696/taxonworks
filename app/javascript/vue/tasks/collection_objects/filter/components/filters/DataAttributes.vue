<template>
  <div>
    <h3>{{ title }}</h3>
    <div>
      <p
        class="middle"
        v-if="dataAttribute.controlled_vocabulary_term_id">
        <span class="margin-small-right">{{ cvtLabel[dataAttribute.controlled_vocabulary_term_id] }}</span>
        <span
          class="button button-circle btn-undo button-default"
          @click="removeCVT"/>
      </p>
      <autocomplete
        v-else
        url="/controlled_vocabulary_terms/autocomplete"
        :add-params="{'type[]' : 'Predicate'}"
        label="label"
        min="2"
        placeholder="Select a predicate"
        clear-after
        @get-item="setCVT"
        class="margin-small-bottom"
        param="term"/>
      <div class="horizontal-left-content">
        <input
          type="text"
          placeholder="Value"
          class="full_width margin-small-right"
          v-model="dataAttribute.value">
        <label class="inline">
          <input
            v-model="dataAttribute.exact"
            type="checkbox">
          Exact
        </label>
      </div>
      <button
        :disabled="!dataAttribute.controlled_vocabulary_term_id"
        type="button"
        class="button normal-input button-default margin-small-top"
        @click="addAttribute">Add
      </button>
    </div>
    <list-component
      :list="list"
      label="label"
      :delete-warning="false"
      @index="removeItem"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import ListComponent from 'components/displayList'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    default: 'Data attribute'
  }
})

const emit = defineEmits(['update:modelValue'])

const dataAttributes = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const list = computed(() => dataAttributes.value.map(item => (
  {
    ...item,
    label: cvtLabel.value[item.controlled_vocabulary_term_id]
  })
))

const makeNewAttribute = () => ({
  controlled_vocabulary_term_id: undefined,
  value: undefined,
  exact: false
})

const dataAttribute = ref(makeNewAttribute())
const cvtLabel = ref({})

const addAttribute = () => {
  dataAttributes.value.push(dataAttribute.value)
  dataAttribute.value = makeNewAttribute()
}

const setCVT = cvt => {
  dataAttribute.value.controlled_vocabulary_term_id = cvt.id
  cvtLabel.value[cvt.id] = cvt.label
}

const removeItem = index => {
  dataAttributes.value.splice(index, 1)
  cvtLabel.value.splice(index, 1)
}

const removeCVT = () => {
  dataAttribute.value.controlled_vocabulary_term_id = undefined
  delete cvtLabel.value[dataAttribute.value.controlled_vocabulary_term_id]
}

</script>
