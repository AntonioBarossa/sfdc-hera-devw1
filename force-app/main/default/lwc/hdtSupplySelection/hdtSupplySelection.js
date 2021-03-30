import { LightningElement,track, api } from 'lwc';
import getCustomMetadata from '@salesforce/apex/HDT_QR_FiltriProcessi.getCustomMetadata';
import getContractFromRow from '@salesforce/apex/HDT_QR_Contract.getContractFromRow';
export default class hdtSupplySelection extends LightningElement {
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    @api saleRecord;
    @api additionalFilter;
    @api showButtonContract = false;
    @api showButtonForniture = false;
    showCreateTargetObjectButton = false;
    showCreateTargetObjectMod = false;
    selectedServicePoint;
    @api disabledInput;
    disabledNext = false;
    hiddenEdit = true;
    @api outputContract;

    /**
     * Show create button when process is undefined
     */
    connectedCallback(){
 

        console.log('connectedCallback START');
        console.log('targetObject 2*****'+ JSON.stringify(this.targetObject));
        console.log('processType '+ JSON.stringify(this.processType));
        if(this.processType === undefined || this.processType === ''){
            console.log('showCreateTargetObjectButton true')
            this.showCreateTargetObjectButton = true;
            this.showCreateTargetObjectMod= true;
            console.log('showButtonContract: ', this.showButtonContract);
        }else{
            getCustomMetadata({processType:this.processType}).then(data =>{
                console.log('data custom metadata '+JSON.stringify(data));
                console.log('data.FornitureCliente__c  '+JSON.stringify(data.FornitureCliente__c ));
                console.log('data.StatoContratto__c  '+JSON.stringify(data.StatoContratto__c ));
                console.log('data.ContrattiCliente__c '+ JSON.stringify(data.ContrattiCliente__c ));

                let statusSplit=[];
                let TipoServizioSplit=[];


                if(data.ContrattiCliente__c =='SI'){
                    this.showButtonContract= true;

                    if(data.StatoContratto__c != undefined && data.StatoContratto__c!='')
                    {

                        statusSplit = data.StatoContratto__c.split(",");
                        console.log('statusSplit *****'+JSON.stringify(statusSplit));
                    }
                }
                if(data.FornitureCliente__c == 'SI'){
                    console.log('entra qui forniture');
                    this.showButtonForniture = true;
                    if(data.TipoServizio__c!= undefined && data.TipoServizio__c!='')
                    {
                        TipoServizioSplit = data.TipoServizio__c.split(",");
                        console.log('TipoServizioSplit *****'+JSON.stringify(TipoServizioSplit));
                    }

                }

               if(statusSplit.length > 1){
                
                    this.showButtonContract= true;
                    this.additionalFilter= 'AND (status =\''+statusSplit[0]+'\''+'OR status = \''+statusSplit[1]+'\')';
                    console.log('entra in contratti si');
                    //this.handleAdditionalFilter(this.processType);
                
               }
               else if(statusSplit.length > 0)
               {

                    this.additionalFilter= 'AND status =\''+data.StatoContratto__c+'\'';
                    // this.handleAdditionalFilter(this.processType);       

               }
                if(TipoServizioSplit.length >1){

                        this.showButtonForniture = true;
                        this.showCreateTargetObjectMod= true;
                        this.additionalFilter='AND (CommoditySector__c = \''+TipoServizioSplit[0]+'\''+'OR CommoditySector__c = \''+TipoServizioSplit[1]+'\')';
                        console.log('AdditionalFilter**********'+JSON.stringify(this.additionalFilter));
                        //this.handleAdditionalFilter(this.processType);
                    
                }
                else if(TipoServizioSplit.length >0)
                {     
                        console.log('entra qui');
                        this.showCreateTargetObjectMod= true;
                        this.additionalFilter='AND CommoditySector__c = \''+data.TipoServizio__c+'\'';
                        console.log('AdditionalFilter**********'+JSON.stringify(this.additionalFilter));
                        //this.handleAdditionalFilter(this.processType);
                    
                }


            });

        }
        
        console.log('connectedCallback END');
    }

    @api
    handleAdditionalFilter(processType){
        let processT = processType;
        console.log('enter in handleAdditionalFilter');
        console.log('processType******************'+JSON.stringify(processT));

        if(processT ==='Voltura Tecnica'){
            console.log('entra qui Modifica***************');
          
            this.template.querySelector("c-hdt-advanced-search").submitFornitura();
        }
        else if(processT==='Cessazioni')
        {
            console.log('entra qui Cessazioni***************');
            this.template.querySelector("c-hdt-advanced-search").submitFornitura();
            
        }
    }
    
    @api
    handleAddFilter(){
        return this.additionalFilter;
    }
    /**
     * Get selected service point
     */
    handleServicePointSelection(event){
        console.log('handleServicePointSelection' + JSON.stringify(event.detail));
        this.selectedServicePoint = event.detail;
        let contractNumber = this.selectedServicePoint['Contract Number'];
        console.log('rowToSend for Contract'+ JSON.stringify(contractNumber));
        
        getContractFromRow({cNumber:contractNumber,accountId:this.AccountId}).then(data=>{
            this.outputContract= data;
            console.log('outputContract *******'+ JSON.stringify(this.outputContract));
        });

        //Creato evento per intercettare sul flow Post Sales il Service Point selezionato
        this.dispatchEvent(new CustomEvent('servicepointselectionflow', {
            detail: event.detail
        }));
    }

    /**

     * Dispatch the new created service point to wizard

     */
    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }

    /**

     * Handle the new tile creation
     */
    handleNewTile(){
        this.template.querySelector('c-hdt-sale-service-items-tiles').getTilesData();
    }

    // toggle(){
    //     this.disabledInput = !this.disabledInput;
    //     this.disabledNext = !this.disabledNext;
    //     this.hiddenEdit = !this.hiddenEdit;
    // }

    // handleNext(){
    //     this.toggle();
    // }

    // handleEdit(){
    //     this.toggle();
    // }
       /**

     * Dispatch confirmed service point
     */
    handleConfirmServicePoint(event){
        console.log('handleConfirmServicePoint');
        let servicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: servicePoint}));
    }

}

