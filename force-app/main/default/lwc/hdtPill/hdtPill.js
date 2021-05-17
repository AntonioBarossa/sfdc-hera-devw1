import { LightningElement, track, api } from 'lwc';

export default class HdtPill extends LightningElement {
    @api rowId;
    @api fieldName;
    @api pillObj;
    @api icon;
    @track showTable = false;
    @track showPill = false;
    relatedToTable = '';
    pillIcon;
    pillLabel;

    connectedCallback(){
        this.pillIcon = this.icon;
        if(this.pillObj.label != '' && this.pillObj.label != undefined){
            //console.log('>>> ' + this.pillObj.label);
            this.pillLabel = this.pillObj.label;
            this.showPill = true;
        }
        if(this.pillObj.relatedTo != '' && this.pillObj.relatedTo != undefined){
            this.relatedToTable = this.pillObj.relatedTo;
        }
    }

    handleRemove(event){
        event.preventDefault();
        this.showPill = false;
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
            this.showPill = true;
            this.showTable = false;
        } catch (e){
            console.log('>>> ERROR: ');
            console.log(e);
        }
    }

}