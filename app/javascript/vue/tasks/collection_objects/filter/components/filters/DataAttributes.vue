<template>
  <div>
    <h3>Data attribute</h3>
    <div>
      <smart-selector
        model="predicates"
        get-url="/controlled_vocabulary_terms/"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{'type[]' : 'Predicate'}"
        :klass="klass"
        @selected="setCVT"
      >
        <smart-selector-item
          :item="dataAttribute.cvt"
          label="name"
          @unset="dataAttribute.cvt = undefined"
        />
      </smart-selector>
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
        :disabled="!dataAttribute.cvt"
        type="button"
        class="button normal-input button-default margin-small-top"
        @click="addAttribute(dataAttribute)">Add
      </button>
    </div>
    <table
      v-if="list.length"
      class="full_width"
    >
      <thead>
        <tr>
          <th>Predicate</th>
          <th>Value</th>
          <th>Exact</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="index"
        >
          <td>{{ item.cvt.name }}</td>
          <td>{{ item.value }}</td>
          <td>
            <input
              type="checkbox"
              v-model="item.exact"
            >
          </td>
          <td>
            <v-btn
              color="primary"
              circle
              @click="removeItem(index)"
            >
              <v-icon
                color="white"
                name="trash"
                x-small
              />
            </v-btn>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  },

  klass: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const list = ref([])

watch(() => props.modelValue, (newVal, oldValue) => {
  if (!newVal.length && oldValue.length) {
    list.value = []
  }
})

watch(list, newList => {
  emit('update:modelValue', newList.map(item => ({
    controlled_vocabulary_term_id: item.cvt.id,
    value: item.value,
    exact: item.exact
  })))
}, { deep: true })

const makeNewAttribute = () => ({
  cvt: undefined,
  value: undefined,
  exact: false
})

const dataAttribute = ref(makeNewAttribute())

const addAttribute = item => {
  list.value.push(item)
  dataAttribute.value = makeNewAttribute()
}

const removeItem = index => {
  list.value.splice(index, 1)
}

const setCVT = cvt => {
  dataAttribute.value.cvt = cvt
}

const urlParams = URLParamsToJSON(location.href)

if (urlParams.data_attributes_attributes) {
  urlParams.data_attributes_attributes.forEach(item => {
    ControlledVocabularyTerm.find(item.controlled_vocabulary_term_id).then(({ body }) => {
      list.value.push({
        cvt: body,
        ...item
      })
    })
  })
}

</script>
