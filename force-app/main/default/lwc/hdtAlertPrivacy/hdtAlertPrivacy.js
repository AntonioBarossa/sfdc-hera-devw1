import { LightningElement,api,track,wire } from 'lwc';
import getRecordTypeAccount from '@salesforce/apex/HDT_LC_AlertPrivacy.handleShowAlert';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Order.DocSendingMethod__c', 'Order.Phase__c','Order.ParentOrder__c'];
export default class HdtAlertPrivacy extends LightningElement {
    @api recordId;
    order;
    @track showAlert = false;
    @track showAlertDoc = false;
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
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.order = data;
            var parentId = this.order.fields.ParentOrder__c.value;
            var sendMethod = this.order.fields.DocSendingMethod__c.value;
            var phase = this.order.fields.Phase__c.value;
            if(parentId){
                this.showAlertDoc = false;
            }else if(sendMethod && phase && sendMethod.localeCompare('Stampa Cartacea') === 0 && phase.localeCompare('Documentazione da firmare') === 0){
                this.showAlertDoc = true;
            }
        }
    }

    /*newCaseClick() {
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
    }*/
}