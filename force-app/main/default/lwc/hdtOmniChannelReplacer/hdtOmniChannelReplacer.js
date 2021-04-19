import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
import getActivities from '@salesforce/apex/HDT_LC_OmniChannelReplacerController.getActivities';
import getSigmaLogin from '@salesforce/apex/HDT_LC_OmniChannelReplacerController.getSigmaLogin';
import QAdLogin__c from '@salesforce/schema/HDT_PEV_activityReceived__c.QAdLogin__c';

export default class hdtOmniChannelReplacer extends NavigationMixin(LightningElement) {
    // subscription = {};
    @api channelName = '/event/HDT_PEV_activityReceived__e';
    qadLogin;
    activities;

    async connectedCallback() {
        this.qadLogin = await getSigmaLogin();
        console.log(await getSigmaLogin());
        this.handleActivities();
        subscribe(this.channelName, -1, function(response) {
            console.log('### ' + response.data.payload.QAdLogin__c);
            console.log('### ' + this.qadLogin);
            console.log(response.data.payload.QAdLogin__c == this.qadLogin);
            if(response.data.payload.QAdLogin__c == this.qadLogin) {
                this.handleActivities.bind(this);
            }
        }.bind(this));
        this.registerErrorListener();
    }

    async handleActivities() {
        this.activities = await getActivities({qadLogin: this.qadLogin});
        this.activities.forEach(a => {
            a.completed = a.wrts_prcgvr__Status__c == 'Completed';
        });
    }

    handleClick(event) {
        var activityId = event.currentTarget.dataset.id;
        var accountId = event.currentTarget.dataset.accountid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId != null ? accountId : activityId,
                actionName: 'view'
            }
        }); 
    }

    handleMouseOver(event) {
        var x = event.currentTarget.dataset.id;
        this.template.querySelector(`[data-id="${x}"]`).classList.add("hovered");
    }

    handleMouseOut(event) {
        var x = event.currentTarget.dataset.id;
        this.template.querySelector(`[data-id="${x}"]`).classList.remove('hovered');
    }

    /* In case you want to unsubscribe use this
    // Handles unsubscribe button click
    handleUnsubscribe() {

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    */
    
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}