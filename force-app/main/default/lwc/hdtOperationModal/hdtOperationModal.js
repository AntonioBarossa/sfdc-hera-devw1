import { LightningElement } from 'lwc';

export default class HdtOperationModal extends LightningElement {

    op = '';

    tempList = [
        {label: 'Operazione 1', name: 'op1', iconName: 'utility:case', desc: 'Esegui operazione 1'},
        {label: 'Operazione 2', name: 'op2', iconName: 'utility:clock', desc: 'Esegui operazione 2'},
        {label: 'Operazione 3', name: 'op3', iconName: 'utility:contact_request', desc: 'Esegui operazione 3'},
        {label: 'Operazione 4', name: 'op4', iconName: 'utility:dialing', desc: 'Esegui operazione 4'},
        {label: 'Operazione 5', name: 'op5', iconName: 'utility:automate', desc: 'Esegui operazione 5'},
        {label: 'Operazione 6', name: 'op6', iconName: 'utility:answered_twice', desc: 'Esegui operazione 6'},
        {label: 'Operazione 7', name: 'op7', iconName: 'utility:cases', desc: 'Esegui operazione 7'},
        {label: 'Operazione 8', name: 'op8', iconName: 'utility:education', desc: 'Esegui operazione 8'},
        {label: 'Operazione 9', name: 'op9', iconName: 'utility:einstein', desc: 'Esegui operazione 9'},
        {label: 'Operazione 10', name: 'op10', iconName: 'utility:search', desc: 'Esegui operazione 10'}
    ];

    get operationValue(){
        return this.tempList;
    }

    clickOperation(event){
        this.op = event.currentTarget.getAttribute('data-id');
        console.log('# Operation -> ' + this.op);
        const closeEvent = new CustomEvent("closeopmodal", {
            detail:  {
                op: this.op,
                runflow: true
            }
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
        this.op = '';
    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closeopmodal", {
            detail:  {
                op: '',
                runflow: false
            }
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}