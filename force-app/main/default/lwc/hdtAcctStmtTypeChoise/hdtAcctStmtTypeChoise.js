import { LightningElement, api } from 'lwc';

export default class HdtAcctStmtTypeChoise extends LightningElement {

    @api stmtType;
    stmtName = '';

    tempList = [
        {label: 'ORDINARIO ', name: 'ordinario', iconName: 'utility:retail_execution', desc: 'imposta questo valore'},
        {label: 'TARI', name: 'tari', iconName: 'utility:record_delete', desc: 'imposta questo valore'},
        {label: 'TARES', name: 'tares', iconName: 'utility:delete', desc: 'imposta questo valore'}
    ];

    get stmtValue(){
        return this.tempList;
    }

    //connectedCallback(){
    //    console.log('#@# ' + this.stmtType);
    //}

    clickOperation(event){
        var dataSet = event.currentTarget.dataset;
        this.stmtName = dataSet.id;

        const closeEvent = new CustomEvent("choisestmt", {
            detail:  {
                stmtName: this.stmtName, stmtLabel: dataSet.label
            }
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
        this.stmtName = '';
    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closestmtchoise", {
            detail:  {
                stmtName: ''
            }
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}