import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getActivity from '@salesforce/apex/HDT_LC_ActivityTrace.getActivity';

export default class HdtActivityTrace extends NavigationMixin(LightningElement) {
    @api activityId;
    @api recordId;
    @track show = false;
    @track actId;
    connectedCallback() {
        getActivity({recordId:this.recordId})
        .then(result => {
            console.log(JSON.stringify('result '+result));
            if(result){
                this.show = true;
                this.actId = result;
            }
        })
        .catch(error => {
            this.show = false;
        });
    }

    handleOnselect(event) {

        var selectedVal = event.detail.value;
        console.log( 'Selected button is ' + selectedVal );

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.actId,
                actionName: 'view',
            }
        });

    }
}