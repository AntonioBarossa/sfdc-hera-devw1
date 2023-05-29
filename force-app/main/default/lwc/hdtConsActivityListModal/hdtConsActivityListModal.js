import { LightningElement, api, track } from 'lwc';

export default class HdtConsActivityListModal extends LightningElement {

    @api modalHeader;
    @api modalBody;
    @api operation;
    @api buttonName;
    @api requestObject;
    enableActivityList2g = false;
    consumptionList2g = false;
    @track tempReqObj = {};

    connectedCallback(){
        console.log('>>> modalHeader: ' + this.modalHeader);
        console.log('>>> modalBody: ' + this.modalBody);
        console.log('>>> operation: ' + this.operation);
        console.log('>>> requestObject: ' + JSON.stringify(this.requestObject));

        for(var i in this.requestObject){
            console.log('>>> obj: ' + this.requestObject[i] + ' - ' + i);
            this.tempReqObj[i] = this.requestObject[i];
        }

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
        console.log('>>> field: ' + event.currentTarget.name + ' - value: ' + event.detail.value);
        this.tempReqObj[event.currentTarget.name] = event.target.value;
    }

    setFilterParam(event) {
        console.log('>>> field: ' + event.currentTarget.name + ' - value: ' + event.detail.value);
        var fieldName = event.currentTarget.name;
        this.tempReqObj[fieldName] = event.target.value.toString();
    }

    buttonClick(event){
        var decision = event.currentTarget.dataset.id;
        const confirmModal = new CustomEvent("confirm", {
            detail:  {
                decision: decision,
                operation: this.operation,
                buttonName: this.buttonName,
                requestObject: this.tempReqObj
            }
        });
        // Dispatches the event.
        this.dispatchEvent(confirmModal);
    }
}