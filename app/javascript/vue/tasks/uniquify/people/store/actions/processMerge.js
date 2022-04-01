import { People } from 'routes/endpoints'

export default ({ state, commit }) => {
  function processMerge (mergeList) {
    const mergePerson = state.mergeList.pop()
    state.preferences.isSaving = true

    People.merge(state.selectedPerson.id, {
      person_to_destroy: mergePerson.id,
      extend: ['roles']
    }).then(({ body }) => {
      const personIndex = state.foundPeople.findIndex(person => person.id === state.selectedPerson.id)

      state.foundPeople = state.foundPeople.filter(people => mergePerson.id !== people.id)
      state.matchPeople = state.matchPeople.filter(people => mergePerson.id !== people.id)

      state.selectedPerson = body

      if (personIndex > -1) {
        state.foundPeople[personIndex] = state.selectedPerson
      }
    }).finally(() => {
      if (state.mergeList.length) {
        processMerge(mergeList)
      } else {
        People.find(state.selectedPerson.id, { extend: ['roles'] }).then(({ body }) => {
          state.selectedPerson = body
          state.isSaving = false
        })
      }
    })
  }

  processMerge(state.mergeList)
}
