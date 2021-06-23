import { LightningElement, api, track } from 'lwc';
import CampaignIcons from '@salesforce/resourceUrl/campaignIcons';
import getAllCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getCampaigns';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtAccountHighlightPanel extends LightningElement {
    @api objectApiName = 'Account';
    @api recordId;
    @api campaignCategory = 'Campagna CRM';
    @api campaignChannel = '';
    @track pageUrl;

    inactiveCampaignsIcon = CampaignIcons + "/inactiveCampaigns.png";
    activeCampaignsIcon = CampaignIcons + "/activeCampaigns.png";
    requiredCampaignsIcon = CampaignIcons + "/requiredCampaigns.jpg";

    @track iconStatus;
    activeCampaigns = [];
    requiredCampaigns = false;

    @track allCampaigns = [];

    connectedCallback(event) {
        this.iconStatus = this.inactiveCampaignsIcon;

        getAllCampaigns({ id: this.recordId, objectName: this.objectApiName, category: this.campaignCategory, channel: this.campaignChannel }).then(data => {
            if (data != null && data.length > 0) {
                this.allCampaigns = data;
                //check for at least one active Inbound Campaign
                this.activeCampaigns = data.filter((item) => {
                    return item.Campaign.Channel__c.includes('Telefonico Inbound');
                });
            }
            //check for at least one active Inbound Required Campaign
            if (this.activeCampaigns.length > 0) {
                this.pageUrl = window.location.href;
                console.log(this.pageUrl);
                this.requiredCampaigns = this.activeCampaigns.some((item) => {
                    return item.Campaign.Required__c === true;
                });
                if (this.requiredCampaigns) {
                    this.iconStatus = this.requiredCampaignsIcon;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Sul Cliente sono presenti Campagne Obbligatorie',
                            message: 'Clicca {0}',
                            messageData: [
                                {
                                    url: this.pageUrl,
                                    label: 'qui'
                                }
                            ],
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
            //console.log(err.body.message);
            console.log(err);
        });
    }
}