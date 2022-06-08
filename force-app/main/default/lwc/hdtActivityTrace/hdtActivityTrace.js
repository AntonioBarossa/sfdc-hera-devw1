import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getActivity from '@salesforce/apex/HDT_LC_ActivityTrace.getActivity';

export default class HdtActivityTrace extends NavigationMixin(LightningElement) {
    @api activityId;
    @api recordId;
    @track show = false;
    @track actId;
    @track intId;
    @track error;
    @track showActivity = false;
    @track showInteraction = false;
    @track label = 'Attività Tracciatura';
    connectedCallback() {
        getActivity({recordId:this.recordId})
        .then(result => {
            var mappa = JSON.parse(result);
            console.log('mappa ' + mappa);
            console.log('result ' + result);
            var tipo = mappa.Tipo;
            if(tipo === 'Interaction'){
                this.intId = mappa.Id;
                this.showInteraction = true;
                this.label = 'Interaction';
                this.show = true;
            }else if(tipo === 'Activity'){
                this.showActivity = true;
                this.actId = result;
                this.show = true;
            }
        })
        .catch(error => {
            this.show = false;
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            console.log('errore ' +this.error);
        });
    }

    handleOnselect(event) {

        var selectedVal = event.detail.value;
        console.log( 'Selected button is ' + selectedVal );
        var recordId = '';
        if(this.actId != null){
            recordId = this.actId;
        }else{
            recordId = this.intId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            }
        });

    }
}