trigger HDT_ContentDocumentLink on ContentDocumentLink (before insert) {
    new HDT_TRH_ContentDocumentLink().run();
}