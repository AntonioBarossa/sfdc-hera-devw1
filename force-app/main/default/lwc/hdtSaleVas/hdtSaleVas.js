import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmAction from '@salesforce/apex/HDT_LC_SaleVas.confirmAction';

export default class hdtSaleVas extends LightningElement {

    isModalVisible = false;
    isInputVisible = false;
    selectedOption = '';
    inputText = '';
    isLoading = false;

    handleModalVisibility(){
        this.isModalVisible = true;
    }

    handleCancelEvent(){
        this.isModalVisible = false;
    }

    radioGroupOptions = [
        {'label': 'Ordini in corso', 'value': 'Ordini in corso'},
        {'label': 'Contratti Attivi', 'value': 'Contratti Attivi'},
        {'label': 'VAS stand alone', 'value': 'VAS stand alone'}
    ];

    handleRadioGroupChange(event) {
        this.selectedOption = event.detail.value;
        this.isInputVisible = (this.selectedOption === 'VAS stand alone');
    }

    handleInputText(event){
        this.inputText = event.detail.value;
    }

    handleConfirmEvent(){
        this.isLoading = true;
        confirmAction({selectedOption:this.selectedOption, inputText:this.inputText}).then(data =>{
            this.isLoading = false;
            this.isModalVisible = false;
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'VAS confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.isLoading = false;
            this.isModalVisible = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }
}