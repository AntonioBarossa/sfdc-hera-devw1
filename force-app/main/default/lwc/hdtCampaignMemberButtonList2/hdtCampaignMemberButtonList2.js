import { LightningElement, track, api } from 'lwc';
import Survey from '@salesforce/resourceUrl/survey';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtCampaignMemberButtonList2 extends NavigationMixin(LightningElement) {
    @track surveyIcon;

    connectedCallback() {
        this.surveyIcon = Survey + "/survey.png";
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