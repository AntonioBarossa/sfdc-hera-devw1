import { LightningElement, api,  } from 'lwc';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';

export default class HdtSupplyCityEnhancedPicklist extends LightningElement {
    
    @api get label(){
        return this._label;
    }
    set label(newValue){
        if(this._label != newValue) this._label = newValue;
    }
    @api inputSupplyCity;
    @api required;
    @api outputSupplyCity;          //OUTPUT ONLY FOR FLOW USING

    @api validate (){
        let isValid = this.required ? this.outputSupplyCity != null : true;
        let msg = isValid? null : 'Selezionare un comune';
        return { isValid : isValid, errorMessage: msg };
    }

    _label = 'Comune di fornitura';

    cityTechnicalData = [];
    cityOptions = [];

    connectedCallback(){
        this.call_getCities();
    }

    call_getCities() {
        console.log('### call_getCities');
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                console.log('### result -> getCities', JSON.stringify(result));
                this.cityTechnicalData = result;
                for (var i = 0; i < result.length; i++) {
                    this.cityOptions=[...this.cityOptions,{label: result[i].CadastralCity__c , value: result[i].CadastralCity__c} ];
                }
            })
            .catch(error => {
                console.error("### call_getCities Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleFieldChange(event) {
        this.outputSupplyCity = event.detail.value;
    }
}