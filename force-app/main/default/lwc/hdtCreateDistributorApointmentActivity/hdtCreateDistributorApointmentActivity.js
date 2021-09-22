import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createActivity from '@salesforce/apex/HDT_LCP_CreateDistributorApointment.createActivity';

import errorLabel from '@salesforce/label/c.Error';

export default class HdtCreateDistributorApointmentActivity extends NavigationMixin(LightningElement) {

    @api recordId;

    isLoading = true;

    connectedCallback(){

        console.log('HdtCreateDistributorApointmentActivity current record Id ' + this.recordId);

        createActivity({
            objectId : this.recordId
        }).then(result => {

            if (result.error == false && result.newActivity != null) {

                const navigateToActivity = new CustomEvent('activitycreated', { detail: {activityId: result.newActivity.Id} });

                this.dispatchEvent(navigateToActivity);

                this.isLoading = false;

            } else {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: errorLabel,
                        message: result.errorMessage,
                        variant: 'error'
                    })
                );

                const errorEvent = new CustomEvent('activityerror');
                this.dispatchEvent(errorEvent);

                console.log(result.errorMessage);
                console.error(result.errorStackTrace)

                this.isLoading = false;
            }

        });

    }

}