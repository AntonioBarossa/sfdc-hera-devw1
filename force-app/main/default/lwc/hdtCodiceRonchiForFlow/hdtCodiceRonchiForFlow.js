import { LightningElement, api } from 'lwc';

import HdtCodiceRonchi from 'c/hdtCodiceRonchi';
import saveAtecoRonchiCodeCase from '@salesforce/apex/HDT_LC_CodiceAteco.saveAtecoRonchiCodeCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtCodiceRonchiForFlow extends HdtCodiceRonchi {

    @api caseRecord;
    @api title;

    handleSaveAtecoCode(){
        this.loading = true;
        saveAtecoRonchiCodeCase({caseRecord: this.caseRecord, params: {atecoCode: this.selectedCode, istatCode: this.selectedIstatCode, ronchiCode: this.ronchiCode, ronchiSubcategory: this.ronchiSubcategory, ronchiDescription: this.ronchiDescription }}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Successo',
                message: 'Codice Ateco salvato con successo',
                variant: 'success',
            }));

            console.log('###Selected Code >>> ' + this.selectedCode)

            this.dispatchEvent(new CustomEvent('update_cod_ateco_details',{ detail: {
                atecoCode: this.selectedCode, 
                ronchiCode: this.ronchiCode,
                ronchiSubcategory: this.ronchiSubcategory,
                ronchiDescription: this.ronchiDescription
            }}));

            this.handleCloseModal();

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

}