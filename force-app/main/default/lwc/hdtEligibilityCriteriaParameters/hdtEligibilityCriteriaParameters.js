import { LightningElement, track } from 'lwc';

export default class HdtEligibilityCriteriaParameters extends LightningElement {

    @track fields = [
       {row: '1', innerList: ['Agenzia', 'Marcatura Cliente']},
       {row: '2', innerList: ['ATC Gas', 'Nuovo Cliente']},
       {row: '3', innerList: ['Campagna', 'Opzione Energia Verde']},
       {row: '4', innerList: ['Canale', 'Opzione Gas Verde']},
       {row: '5', innerList: ['Categoria Uso', 'Prodotto']},
       {row: '6', innerList: ['Codice Criterio', 'Provenienza']},
       {row: '7', innerList: ['Company Owner', 'Raggruppamento di Login']},
       {row: '8', innerList: ['Eta Cliente', 'Ruolo Profilo']},
       {row: '9', innerList: ['Fascia', 'Tipo Apparecchiatura']},
       {row: '10', innerList: ['Login', 'Tipo Cliente Categoria']}
    ];

}