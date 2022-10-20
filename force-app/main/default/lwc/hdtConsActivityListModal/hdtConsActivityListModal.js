import { LightningElement, api } from 'lwc';

export default class HdtConsActivityListModal extends LightningElement {

    @api modalHeader;
    @api modalBody;
    @api operation;
    @api requestObject;
    enableActivityList2g = false;
    consumptionList2g = false;

    connectedCallback(){
        console.log('>>> modalHeader: ' + this.modalHeader);
        console.log('>>> modalBody: ' + this.modalBody);
        console.log('>>> operation: ' + this.operation);
        console.log('>>> requestObject: ' + JSON.stringify(this.requestObject));

        switch (this.operation) {

            case "consumptionList2g"://Elenco Consumi 2G
                this.consumptionList2g = true;
            break;

            case "activityList2g": //Elenco Attività 2G
                this.enableActivityList2g = true;
            break;

        }

    }

    get options() {
        return [
            { label: 'Cambio fascia/giorno di Default', value: 'D' },
            { label: 'Programmazione fascia/giorno una tantum', value: 'P' },
            { label: 'Cancellazione della programmazione', value: 'R' }
        ];
    }

    handleChange(event) {
        console.log('>>> value: ' + event.detail.value);
        //var fieldName = event.currentTarget.name;
        var reqObj = JSON.parse(this.requestObject);
        reqObj.idService = event.target.value;
        console.log('>>> requestObject: ' + reqObj);
    }

    setFilterParam(event) {
        console.log('>>> field: ' + event.currentTarget.name + ' - value: ' + event.detail.value);
        var fieldName = event.currentTarget.name;

        var reqObj = JSON.parse(this.requestObject);
        console.log('>>> requestObject: ' + reqObj);

        reqObj[fieldName] = event.target.value.toString();
        console.log('>>> requestObject: ' + reqObj);
    }

    buttonClick(event){
        const confirmModal = new CustomEvent("confirm", {
            detail:  {
                operation: this.operation,
                requestObject: this.requestObject
            }
        });
        // Dispatches the event.
        this.dispatchEvent(confirmModal);
    }
}