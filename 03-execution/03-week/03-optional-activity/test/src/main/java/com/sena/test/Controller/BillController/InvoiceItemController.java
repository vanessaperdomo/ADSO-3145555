package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.InvoiceItemDto;
import com.sena.test.Service.BillService.InvoiceItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/invoice-item")
@CrossOrigin(origins = "*")
public class InvoiceItemController {

    @Autowired
    private InvoiceItemService invoiceItemService;

    @GetMapping
    public List<InvoiceItemDto> getAll() {
        return invoiceItemService.getAll();
    }

    @GetMapping("/{id}")
    public InvoiceItemDto getById(@PathVariable UUID id) {
        return invoiceItemService.getById(id);
    }

    @PostMapping
    public InvoiceItemDto create(@RequestBody InvoiceItemDto dto) {
        return invoiceItemService.create(dto);
    }

    @PutMapping("/{id}")
    public InvoiceItemDto update(@PathVariable UUID id, @RequestBody InvoiceItemDto dto) {
        return invoiceItemService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        invoiceItemService.delete(id);
        return "Eliminado exitosamente";
    }
}