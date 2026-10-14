@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View for ZDMO01'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'CustomerID' ]
define root view entity ZC_ZDMO01
  provider contract transactional_query
  as projection on ZR_ZDMO01
{
  key CustomerID,
      CustomerName,
      Title,
      Street,
      PostalCode,
      City,
      CountryCode,
      PhoneNumber,
      EmailAddress,

      @Semantics.largeObject: { mimeType: 'Mimetype',
                                fileName: 'Filename',
                                contentDispositionPreference: #ATTACHMENT }
      Attachment,
      @Semantics.mimeType: true
      Mimetype,
      Filename,
      ExportedBy,
      ExportedAt
}
