import { LightningElement, api} from 'lwc';

export default class HdtChooseTypeModal extends LightningElement {
    @api stmtType;
    stmtName = '';
    @api tempList;

    get stmtValue(){
        return this.tempList;
    }

    clickOperation(event){
        var dataSet = event.currentTarget.dataset;

        console.log('>>> oldType: ' + this.stmtType + ' - newType: ' + dataSet.id);

        if(this.stmtType == dataSet.id){
            this.closeModal();
        } else {
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

    }

    closeModal(){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closestmtchoise", {
            detail: {booleanVar: 'showAcctStmt'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}