import { LightningElement, api, track, wire } from 'lwc';
import CAMPAIGN_ICONS from '@salesforce/resourceUrl/campaignIcons';
import getAllCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getCampaigns';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class HdtAccountHighlightPanel extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api campaignCategory = 'Campagna CRM';
    @api campaignChannel = '';

    inactiveCampaignsIcon = CAMPAIGN_ICONS + "/inactiveCampaigns.png";
    activeCampaignsIcon = CAMPAIGN_ICONS + "/activeCampaigns.png";
    requiredCampaignsIcon = CAMPAIGN_ICONS + "/requiredCampaigns.jpg";

    @track iconStatus;
    activeCampaigns = [];
    requiredCampaigns = false;

    @track allCampaigns = [];

    connectedCallback(event) {
        getAllCampaigns({ id: this.recordId, objectName: this.objectApiName, category: this.campaignCategory, channel: this.campaignChannel }).then(data => {
            this.allCampaigns = data;
            //check for at least one active Inbound Campaign
            this.activeCampaigns = data.filter((item) => {
                return item.Campaign.Channel__c.includes('Telefonico Inbound');
            });
            //check for at least one active Inbound Required Campaign
            if (this.activeCampaigns.length > 0) {
                this.requiredCampaigns = this.activeCampaigns.some((item) => {
                    return item.Campaign.Required__c === true;
                });
                if (this.requiredCampaigns) {
                    this.iconStatus = this.requiredCampaignsIcon;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Sul Cliente sono presenti Campagne Obbligatorie',
                            message: '',
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                } else {
                    this.iconStatus = this.activeCampaignsIcon;
                }
            } else {
                this.iconStatus = this.inactiveCampaignsIcon;
            }
        }).catch(err => {
            console.log(err.body.message);
        });
    }
}