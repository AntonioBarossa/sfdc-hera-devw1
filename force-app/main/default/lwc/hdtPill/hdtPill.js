import { LightningElement, track, api } from 'lwc';

export default class HdtPill extends LightningElement {
    @api rowId;
    @api fieldName;
    @api pillObj;
    @api icon;
    @api rate;
    @api rateTypeValue;
    @track showTable = false;
    @track showPill = false;
    relatedToTable = '';
    pillIcon;
    pillLabel;
    pillValue;

    connectedCallback(){
        //console.log('>>> PILL ' + JSON.stringify(this.pillObj));

        this.pillIcon = this.icon;
        if(this.pillObj.value != undefined && this.pillObj.value != '' && this.pillObj.label != undefined && this.pillObj.label != ''){
            this.pillLabel = this.pillObj.label;
            this.pillValue = this.pillObj.value;
            this.showPill = true;
        }

        if(this.pillObj.relatedTo != '' && this.pillObj.relatedTo != undefined){
            this.relatedToTable = this.pillObj.relatedTo;
        }

    }

    handleRemove(event){

        console.log('@ rowId -> ' + this.rowId + ' - fieldName -> ' + this.fieldName);

        event.preventDefault();
        this.showPill = false;

        const selectedEvent = new CustomEvent("setvaluetoparent", {
            detail:  {
                        rowId: this.rowId,
                        fieldName: this.fieldName,
                        recId: null,
                        label: null
                    }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

    openModal(event){
        console.log('@ currentRowId -> ' + this.rowId + ' # ' + this.fieldName);
        this.showTable = true;
    }

    hanldeCloseMOdal(event){
        this.showTable = false;
    }

    hanldeSetValue(event) {
        console.log('# pills:' + event.detail.rowId + '; ' + event.detail.fieldName);
        console.log('# pills: ' + event.detail.recId + '; ' + event.detail.label);

        try{
            const selectedEvent = new CustomEvent("setvaluetoparent", {
                detail:  {
                            rowId: event.detail.rowId,
                            fieldName: event.detail.fieldName,
                            recId: event.detail.recId,
                            label: event.detail.label
                        }
            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.pillIcon = event.detail.icon;
            this.pillLabel = event.detail.label;
            this.pillValue = event.detail.recId;
            this.showPill = true;
            this.showTable = false;
        } catch (e){
            console.log('>>> ERROR: ');
            console.log(e);
        }
    }

}