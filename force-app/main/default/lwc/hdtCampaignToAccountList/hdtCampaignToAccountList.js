import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getCampaigns';
import updateCampaignMembersStatus from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMembersStatus';


const columns = [
    { label: 'Campagna', fieldName: 'Name' },
    { label: 'Stato', fieldName: 'Status' },
    { label: 'Canale', fieldName: 'Channel__c' },
    { label: 'Close Date', fieldName: 'EndDate', type: 'date' },
];
export default class PopoverContainer extends NavigationMixin(LightningElement) {
    @api campaignType;
    @api objectApiName;
    @api entityId;
    @api campaignCategory;
    @api campaignChannel;
    @api title = '';
    @api showTag = false;
    @track allCampaigns = [];
    @track rowdata = [];
    @track isSale = false;
    @track selectedCampaignId = null;
    @track campaignsNumber = 0;
    @track listResults = false;
    @track campaignsResult = [];

    @wire(getAllCampaigns, { id: '$entityId', objectName: '$objectApiName', category: '$campaignCategory', channel: '$campaignChannel' }) campaigns(result) {
        this.campaignsResult = result;
        this.allCampaigns = [];
        this.campaignsNumber = 0;
        if (result.error) {
            console.log(error);
        } else if (result.data) {
            if (result.data.length !== 0) {
                console.log('CAMPAIGNMEMBERS --> '+JSON.stringify(result.data));
                result.data.forEach(item => {
                    this.allCampaigns.push(item);
                    this.campaignsNumber++;
                    let row = {
                        "Id" : item.Campaign.Id,
                        "Name" : item.Campaign.Name,
                        "Status" : item.Status,
                        "Channel__c" : item.Campaign.Channel__c,
                        "EndDate" : item.Campaign.EndDate
                    };
                    this.rowdata.push(row);
                });
                //this.rowdata = this.allCampaigns;
                console.log(JSON.stringify(this.rowdata));
                this.listResults = true;
                
                //send visibility to parent component
                this.dispatchEvent(new CustomEvent('emitvisibility', {
                    detail: {
                        isVisible: this.listResults
                    }
                }));
                this.showTag = true;
            }
        }
    }
    columns = columns;
    connectedCallback() {
        this.isSale = this.campaignType == "sale" ? true : false;
    }

    handleCampaignsUpdate() {
        refreshApex(this.campaignsResult);
    }

    handleRowSelection(event) {
        this.selectedCampaignId = event.target.selectedRows[0];

        //send selectedCampaignId to parent component
        this.dispatchEvent(new CustomEvent('emitcampaignid', {
            detail: {
                campaignId: this.selectedCampaignId
            }
        }));
    }

    redirectToCampaign(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.getAttribute("data-id"),
                objectApiName: 'CampaignMember',
                actionName: 'view'
            },
        });
    }

    @api updateCampaignMemberStatus() {
        let statusValue = 'Non Proposto Auto';
        let membersToUpdate = [];
        this.campaignsResult.data.forEach(elem => {
            if(elem.Campaign.Required__c == true && elem.Campaign.Category__c == 'Campagna CRM') {
                membersToUpdate.push(elem.Id);
            }
        });
        console.log(JSON.stringify(membersToUpdate));
        if (membersToUpdate.length > 0) {
            updateCampaignMembersStatus({ 'campaignMemberIds': membersToUpdate, 'statusValue': statusValue }).then(data => {
                console.log("ok " + JSON.stringify(data));
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'Stato impostato a "Non Proposto Auto"',
                    variant: 'success'
                }));
            }).catch(err => {
                console.log(err);
            });
        }

    }
}