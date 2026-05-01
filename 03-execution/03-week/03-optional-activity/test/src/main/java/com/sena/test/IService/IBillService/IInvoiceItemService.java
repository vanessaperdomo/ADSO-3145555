package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.InvoiceItemDto;
import java.util.List;
import java.util.UUID;

public interface IInvoiceItemService {
    List<InvoiceItemDto> getAll();

    InvoiceItemDto getById(UUID id);

    InvoiceItemDto create(InvoiceItemDto dto);

    InvoiceItemDto update(UUID id, InvoiceItemDto dto);

    void delete(UUID id);
}