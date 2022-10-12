import { LightningElement, api, track} from 'lwc';
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
    @api outputSupplyCity;

    @api validate (){
        let isValid = this.required ? this.outputSupplyCity != null : true;
        let msg = isValid? null : 'Selezionare un comune';
        return { isValid : isValid, errorMessage: msg };
    }

    @track textInputValue = null;
    @track cityFilteredOptions = [];

    _label = 'Comune di fornitura';
    cityTechnicalData = [];
    cityOptions = [];

    get valueSelected(){
        return this.outputSupplyCity != null && this.outputSupplyCity !== "";
    }
    
    // get cityFilteredOptions(){
    //     if(this.textInputValue != null && this.textInputValue.length > 3){
    //         let filteredOptions = [];
    //         this.cityOptions.forEach( curOpt => {
    //             if(curOpt.value.toUpperCase().includes(this.textInputValue.toUpperCase())) filteredOptions.push(curOpt);
    //         });
    //         return filteredOptions;
    //     }
    //     else return [];
    // }

    connectedCallback(){
        this.outputSupplyCity = this.inputSupplyCity;
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

    handleTextKeyup(event) {
        this.textInputValue = event.target.value;
        if(this.textInputValue != null && this.textInputValue.length >= 3){
            let found = false;
            this.cityOptions.forEach( curOpt => {
                if(curOpt.value.toUpperCase() === this.textInputValue.toUpperCase()){
                    found = true;
                    this.outputSupplyCity = curOpt.value;
                }
            });
            if(!found){
                let filteredOptions = [];
                this.cityOptions.forEach( curOpt => {
                    if(curOpt.value.toUpperCase().includes(this.textInputValue.toUpperCase())) filteredOptions.push(curOpt);
                });
                this.cityFilteredOptions = filteredOptions;
            }
        }
        else this.cityFilteredOptions = [];
    }

    handleRemoveButton(){
        this.outputSupplyCity = null;
        this.textInputValue = null;
        this.cityFilteredOptions = [];
    }
    
}