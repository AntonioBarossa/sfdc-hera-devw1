import { LightningElement, api, track } from 'lwc';
import handleSearch from '@salesforce/apex/HDT_LC_CheckAssessments.handleSearch';

const columns = [ { label: 'Nr. Atto', fieldName: 'NrAtto',  sortable: "true"}, //OK
                  { label: 'Data Atto', fieldName: 'DataAtto', sortable: "true"},
                  { label: 'Tipo Tributo', fieldName: 'TipoTributo'},
                  { label: 'Accertamento per', fieldName: 'AccertamentoPer' },
                  { label: 'Stato', fieldName: 'Stato' },
                  { label: 'Base Dati', fieldName: 'BaseDati'},
                  { label: 'Data Inizio', fieldName: 'DataInizio', sortable: "true"},
                  { label: 'Data Fine', fieldName: 'DataFine' },
                  { label: 'Soggetto', fieldName: 'Soggetto'},
                  { label: 'Indirizzo', fieldName: 'Indirizzo'},
                  { label: 'Civico', fieldName: 'Civico'},
                  { label: 'Contratto', fieldName: 'Contratto'},
                  { label: 'Superficie Accertata', fieldName: 'SuperficieAccertata'},
                  { label: 'Categoria Accertata', fieldName: 'CategoriaAccertata'}];

export default class HdtCheckAssessments extends LightningElement {
    @api fiscalCode;
    @api supplyCity;
    @api customerMarking;
    @track data;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


    connectedCallback(){
        console.log('CallBack start');

        handleSearch({
            cfPiva : this.fiscalCode,
            comuneFornitura : this.supplyCity,
            tipoPersona : this.CustomerMarking,
        }).then(result =>{
            if (!result){
                console.log('result ->' + this.result);
            }else{
                let data = JSON.parse(result);
                let slots = [];
                try{
                    slots = data.data;
                    this.data = [];
                    if(slots.length == 0){

                    }
                    else{
                        slots.forEach(element => {
                            this.addRecord({
                                NrAtto : element.NrAtto,
                                DataAtto : element.DataAtto,
                                TipoTributo : element.TipoTributo,
                                AccertamentoPer : element.AccertamentoPer,
                                Stato : element.Stato,
                                BaseDati : element.BaseDati,
                                DataInizio : element.DataInizio,
                                DataFine : element.DataFine,
                                Soggetto : element.Soggetto,
                                Indirizzo : element.Indirizzo,
                                Civico : element.Civico,
                                Contratto : element.Contratto,
                                SuperficieAccertata : element.SuperficieAccertata,
                                CategoriaAccertata : element.CategoriaAccertata
                            });
                        });
                        this.data.sort(this.sortBy('NrAtto', -1));
                    }
                }catch(e){
                    console.error(e);
                    this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                }
            } 
        }).catch(error =>{
            this.showAlert('Attenzione',error.body.message,'error');
        });
    }

    addRecord(element){
        this.data = [...this.data,element];
    }

    showAlert(_title,_message,_variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: _title,
                message: _message,
                variant: _variant
            })
        );
    }
            
}
