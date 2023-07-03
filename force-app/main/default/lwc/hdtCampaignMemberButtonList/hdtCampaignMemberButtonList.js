import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewCase from '@salesforce/apex/HDT_LC_CampaignsController.getServiceCatalogUrlByCaseType';
import getCampaignAndAccountByMember from '@salesforce/apex/HDT_LC_CampaignsController.getCampaignAndAccountByMember';
export default class hdtCampaignMemberButtonList extends NavigationMixin(LightningElement) {
    @api recordId;
    caseObj = null;
    CampaignProcessType = '';
    processType = '';
    connectedCallback() {
        getCampaignAndAccountByMember({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            this.CampaignProcessType = data.Campaign.ProcessType__c;
            console.log('CampaignProcessType --> '+this.CampaignProcessType);
            this.caseObj = {
                'Subject': 'PostVendita',
                'AccountId': data?.Contact?.AccountId,
                'Cluster__c': data.Campaign.CaseCategory__c,
                'Type': data.Campaign.CaseSubCategory__c,
                'Campaign__c': data.CampaignId,
                'Lead__c' : data.LeadId
            };
            console.log(JSON.stringify(this.caseObj));
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });
    }

    newCaseClick() {
        if(this.caseObj != null && (this.caseObj.AccountId != null || this.caseObj.Lead__c != null)){
            createNewCase({ c: this.caseObj }).then(data => {
                console.log('case --> '+JSON.stringify(data));
                
                //navigate to new created case
                if (data != null) {
                    let query = data.split('?')[1];




                    let params = query.split('&');
                    let obj = {};
                    params.forEach(param => {
                        let elem = param.split('=');
                        obj[elem[0]] = elem[1];
                    });
                    this.processType = obj['c__processType'];
                    do{
                        this.processType = this.processType.replace('+',' ');
                    }
                    while(this.processType.includes("+"));

                   // console.log(JSON.stringify(obj));
                  //  window.open('/post-sale-process-new-case?' + query);
                    this[NavigationMixin.GenerateUrl]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "PostSaleProcessNewCase__c"
                        },
                        state: {
                            // c__processType: obj['c__processType'].replace('+',' '),
                            c__processType: this.processType,
                            c__recordTypeName: obj['c__recordTypeName'],
                            c__accid: obj['c__accid'],
                            c__flowName: obj['c__flowName'],
                            c__campaignId: obj['c__campaignId'],
                            c__campaignMemberId: this.recordId
                        }
                    }).then(url => {
                       window.open(url, "_self");
                    });
                }
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `${error.status}`,
                        message: `${error.body.message}`,
                        variant: "error"
                    })
                );
            });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `error`,
                    message: 'Innesca il Processo dalla Pagina dell\'account',
                    variant: "error"
                })
            );
        }
    }

    get manageDisable(){
        return this.CampaignProcessType == 'Nuova Vendita' || this.CampaignProcessType == '';
    }
}