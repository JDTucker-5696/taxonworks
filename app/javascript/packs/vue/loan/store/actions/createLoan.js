import { MutationNames } from '../mutations/mutations'
import { createLoan } from '../../request/resources'

export default function ({ commit, state }, object) {
  commit(MutationNames.SetSaving, true)
  createLoan({ loan: object }).then(response => {
    TW.workbench.alert.create('Loan was successfully created.', 'notice')
    commit(MutationNames.SetLoan, response)
    commit(MutationNames.SetSaving, false)
    history.pushState(null, null, `/tasks/loans/edit_loan/${response.id}`)
  })
};
