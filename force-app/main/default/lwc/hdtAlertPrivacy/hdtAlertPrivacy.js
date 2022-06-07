import { LightningElement,api,track } from 'lwc';
import getRecordTypeAccount from '@salesforce/apex/HDT_LC_AlertPrivacy.handleShowAlert';
export default class HdtAlertPrivacy extends LightningElement {
    @api recordId;
    @track showAlert = false;
    connectedCallback(){

        getRecordTypeAccount({orderId: this.recordId })
        .then(result => {
            console.log(JSON.stringify('result '+result));
            if(result){
                this.showAlert = true;
            }
        })
        .catch(error => {
            this.showAlert = false;
        });
    }

    newCaseClick() {
        if(this.caseObj.AccountId != null && this.caseObj != null){
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
}