import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
import getActivities from '@salesforce/apex/HDT_LC_OmniChannelReplacerController.getActivities';
import getSigmaLogin from '@salesforce/apex/HDT_LC_OmniChannelReplacerController.getSigmaLogin';

export default class hdtOmniChannelReplacer extends NavigationMixin(LightningElement) {
    @api channelName = '/event/HDT_PEV_activityReceived__e';
    qadLogin;
    @track activities;

    async connectedCallback() {
        this.qadLogin = await getSigmaLogin();
        this.handleActivities();
        subscribe(this.channelName, -1, function(response) {
            if(response.data.payload.QAdLogin__c == this.qadLogin) {
                if(response.data.payload.isNew__c) {
                    this.activities.unshift({
                        Id: response.data.payload.Id__c,
                        Name: response.data.payload.Name__c,
                        Account__c: response.data.payload.Account__c,
                        wrts_prcgvr__Status__c: response.data.payload.Status__c,
                        completed: response.data.payload.Status__c == 'Completed'
                    });
                } else {
                    this.activities.forEach(a => {
                        if(a.Id == response.data.payload.Id__c) {
                            a.Account__c = response.data.payload.Account__c;
                            a.wrts_prcgvr__Status__c = response.data.payload.Status__c;
                            a.completed = a.wrts_prcgvr__Status__c == 'Completed';
                        }
                    });
                }
            }
        }.bind(this));
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

    getDataId(event) {
        return event.currentTarget.dataset.id;
    }
    
    handleMouseOver(event) {
        this.template.querySelector(`[data-id="${this.getDataId(event)}"]`).classList.add("hovered");
    }

    handleMouseOut(event) {
        this.template.querySelector(`[data-id="${this.getDataId(event)}"]`).classList.remove('hovered');
    }
}