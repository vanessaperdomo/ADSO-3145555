package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.OrderItemDto;
import com.sena.test.Service.BillService.OrderItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/order-item")
@CrossOrigin(origins = "*")
public class OrderItemController {

    @Autowired
    private OrderItemService orderItemService;

    @GetMapping
    public List<OrderItemDto> getAll() {
        return orderItemService.getAll();
    }

    @GetMapping("/{id}")
    public OrderItemDto getById(@PathVariable UUID id) {
        return orderItemService.getById(id);
    }

    @PostMapping
    public OrderItemDto create(@RequestBody OrderItemDto dto) {
        return orderItemService.create(dto);
    }

    @PutMapping("/{id}")
    public OrderItemDto update(@PathVariable UUID id, @RequestBody OrderItemDto dto) {
        return orderItemService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        orderItemService.delete(id);
        return "Eliminado exitosamente";
    }
}
