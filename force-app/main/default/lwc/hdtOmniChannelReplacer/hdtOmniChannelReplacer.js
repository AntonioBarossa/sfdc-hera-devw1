import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe } from 'lightning/empApi';
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
                        Lead__c: response.data.payload.Lead__c,
                        Account__c: response.data.payload.Account__c,
                        wrts_prcgvr__Status__c: response.data.payload.Status__c,
                        completed: response.data.payload.Status__c == 'Completed'
                    });
                    // this.dispatchEvent(new CustomEvent('newactivity'));  // UNCOMMENT TO RE ENABLE NOTIFICATION IN UTILITY BAR
                    var activity = this.activities[0];
                    var target = activity.Account__c;
                    if(!target) {
                        if(activity.Lead__c) {
                            target = activity.Lead__c;
                        } else {
                            target = activity.Id;
                        }
                    }
                    this.navigate(target);
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

    navigate(target) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: target,
                actionName: 'view'
            }
        });
    }

    handleClick(event) {
        this.navigate(event.currentTarget.dataset.accountid, event.currentTarget.dataset.id);
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