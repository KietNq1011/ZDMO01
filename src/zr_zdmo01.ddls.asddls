@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Root View for ZDMO01'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_ZDMO01
  as select from    ZI_ZDMO01                                                 as Customer
    -- file bảng kê đã xuất (ZCL_XLSX_ATT_EXPORT), mỗi customer giữ 1 file mới nhất
    left outer join ZI_ATTACHMENT_DMO( p_module_obj: 'DMO', p_app_id: 'ZDMO01' ) as File
                    on File.DocumentId = cast( Customer.CustomerID as zde_document_id_dmo )
{
  key Customer.CustomerID,
      Customer.CustomerName,
      Customer.Title,
      Customer.Street,
      Customer.PostalCode,
      Customer.City,
      Customer.CountryCode,
      Customer.PhoneNumber,
      Customer.EmailAddress,

      @Semantics.largeObject: { mimeType: 'Mimetype',
                                fileName: 'Filename',
                                contentDispositionPreference: #ATTACHMENT }
      File.Attachment,
      @Semantics.mimeType: true
      File.Mimetype,
      File.Filename,
      File.CreatedBy as ExportedBy,
      File.CreatedAt as ExportedAt
}
