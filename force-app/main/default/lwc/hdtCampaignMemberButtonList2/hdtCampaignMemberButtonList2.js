import { LightningElement, track, api, wire } from 'lwc';
import Survey from '@salesforce/resourceUrl/survey';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getScriptNameFromCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getScriptNameFromCampaign';



export default class hdtCampaignMemberButtonList2 extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @track surveyIcon;
    @wire(getScriptNameFromCampaign, {memberId: '$recordId'}) scriptName;

    connectedCallback() {
        this.surveyIcon = Survey + "/survey.png";
        console.log(this.objectApiName);
        console.log(this.recordId);
    }

    hanldeSurveySize(event) { //Start  HRAWRM-544 10-09-2021
        let mEvent= event.detail;
        console.log('mEvent '+mEvent);
        if (mEvent>0) {
            this.template.querySelector('[data-id="divImg"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="divImg"]').classList.add('slds-show');
        }
        else{
            this.template.querySelector('[data-id="divImg"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="divImg"]').classList.remove('slds-show');
        }
      }//End  HRAWRM-544 10-09-2021
    surveyClick() {
        this.template.querySelector('c-hdt-campaign-survey').openModal();
    }

    scriptHelpSaleClick() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Non è disponibile lo script per questa campagna',
                message: '',
                variant: 'error'
            })
        );
    }
}