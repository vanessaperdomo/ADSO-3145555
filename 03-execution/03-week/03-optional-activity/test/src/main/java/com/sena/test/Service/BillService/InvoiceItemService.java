package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.InvoiceItemDto;
import com.sena.test.Entity.Bill.Invoice;
import com.sena.test.Entity.Bill.InvoiceItem;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.IRepository.IBillRepository.IInvoiceItemRepository;
import com.sena.test.IRepository.IBillRepository.IInvoiceRepository;
import com.sena.test.IRepository.IInventoryRepository.IProductRepository;
import com.sena.test.IService.IBillService.IInvoiceItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class InvoiceItemService implements IInvoiceItemService {

    @Autowired
    private IInvoiceItemRepository repository;

    @Autowired
    private IInvoiceRepository invoiceRepository;

    @Autowired
    private IProductRepository productRepository;

    private InvoiceItemDto toDto(InvoiceItem e) {
        InvoiceItemDto dto = new InvoiceItemDto();
        dto.setId(e.getId());
        dto.setInvoiceId(e.getInvoice().getId());
        dto.setProductId(e.getProduct().getId());
        dto.setQuantity(e.getQuantity());
        dto.setPrice(e.getPrice());
        return dto;
    }

    private InvoiceItem toEntity(InvoiceItemDto dto) {
        InvoiceItem e = new InvoiceItem();
        Invoice invoice = invoiceRepository.findById(dto.getInvoiceId()).orElse(null);
        e.setInvoice(invoice);
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        e.setQuantity(dto.getQuantity());
        e.setPrice(dto.getPrice());
        return e;
    }

    @Override
    public List<InvoiceItemDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public InvoiceItemDto getById(UUID id) {
        InvoiceItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public InvoiceItemDto create(InvoiceItemDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public InvoiceItemDto update(UUID id, InvoiceItemDto dto) {
        InvoiceItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        Invoice invoice = invoiceRepository.findById(dto.getInvoiceId()).orElse(null);
        e.setInvoice(invoice);
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        e.setQuantity(dto.getQuantity());
        e.setPrice(dto.getPrice());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}