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
export default class hdtCampaignToAccountList2 extends NavigationMixin(LightningElement) {
    @api campaignType;
    @api objectApiName;
    @api title = '';
    @api showTag = false;
    @api entityId;
    @api campaignCategory;
    @api campaignChannel;
    @api selectedCampaignId = null;
    @track allCampaigns = [];
    @track rowdata = [];
    @track isSale = false;
    //@track selectedCampaignId = null;
    @track campaignsNumber = 0;
    @track listResults = false;
    @track campaignsResult = [];
    selectedCampaigns = [];

    @wire(getAllCampaigns, { id: '$entityId', objectName: '$objectApiName', category: '$campaignCategory', channel: '$campaignChannel' }) campaigns(result) {
        this.campaignsResult = result;
        this.allCampaigns = [];
        this.campaignsNumber = 0;
        //HRAWRM-319 [Start] - Logic for making it visible which campaign was already selected
        if (this.selectedCampaignId != null) {
            this.selectedCampaigns.push(this.selectedCampaignId);
        }
        //HRAWRM-319 [End]
        console.log('********');
        if (result.error) {
            console.log('*******:' + error);
        } else if (result.data) {
            console.log('*******DENTRO RESULT:' + JSON.stringify(result));
            if (result.data.length !== 0) {
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
                this.dispatchEvent(new CustomEvent('emitvisibility2', {
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
        console.log('Try:*****');
           this.selectedCampaignId = event.target.selectedRows[0];
        console.log('Try:*****');
        //send selectedCampaignId to parent component
        this.dispatchEvent(new CustomEvent('emitcampaignid2', {
            detail: {
                campaignId: this.selectedCampaignId
            }
        }));
        console.log('Try:*****');
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