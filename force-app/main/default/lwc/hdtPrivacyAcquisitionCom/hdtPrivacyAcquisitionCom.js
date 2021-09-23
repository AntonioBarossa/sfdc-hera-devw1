import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtPrivacyAcquisitionCom  extends NavigationMixin(LightningElement) {
    @api myrecord;
    connectedCallback(){
        console.log('***recordId:'+ recordId);
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                name: "PostSaleProcessNewCase__c"
            },
            state: {
                c__processType:'Modifica Privacy' ,
                c__recordTypeName: 'HDT_RT_GestionePrivacy',
                c__leadId: this.myrecord,
                c__flowName: 'HDT_FL_PostSalesMasterDispatch',
              
            }
        }).then(url => {
           window.open(url, "_blank");
        });
    }

}