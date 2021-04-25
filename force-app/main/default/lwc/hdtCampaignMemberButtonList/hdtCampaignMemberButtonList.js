import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtCampaignMemberButtonList extends NavigationMixin(LightningElement) {
    @api recordId;
}