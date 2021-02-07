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
    disabledInput = false;
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
        }else{
            getCustomMetadata({processType:this.processType}).then(data =>{
                console.log('data custom metadata '+JSON.stringify(data));
                
                if(data.ContrattiCliente__c =='SI'){
                    //cambia stato bottone contratti cliente 
                    this.showButtonContract= true;
                    this.additionalFilter= 'AND status =\''+data.StatoContratto__c+'\'';
                    console.log('entra in contratti si');
                    
                }
                if(data.FornitureCliente__c == 'SI'){
                    this.showButtonForniture = true;
                    this.showCreateTargetObjectMod= true;

                    this.additionalFilter='AND CommoditySector__c = \''+data.TipoServizio__c+'\'';
                    console.log('AdditionalFilter**********'+JSON.stringify(this.additionalFilter));
                    //cambia stato bottone forniture cliente 
                    console.log('entra in forniture si');
                }
            });
            //richiamare classe di query del custom metadata passandogli il processType
            //if(contrattiClienti__c == si) abiliti pulsante contratti cliente
            //if(fornitureclienti == si) abiliti pulsante forniture clienti
            //valorizzare additionalfilter coi valori recuperati dalla query
        }
        
        console.log('connectedCallback END');
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

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleNext(){
        this.toggle();
    }

    handleEdit(){
        this.toggle();
    }
       /**

     * Dispatch confirmed service point
     */
    handleConfirmServicePoint(event){
        console.log('handleConfirmServicePoint');
        let servicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: servicePoint}));
    }

}

