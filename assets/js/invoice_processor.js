// This is a self-executing anonymous function to avoid polluting the global scope.
(() => {
  // These placeholders will be replaced by the Dart code with actual JSON data.
  const cartItems = __CART_ITEMS__;
  const flatRates = __FLAT_RATES__;
  const specialRates = __SPECIAL_RATES__;

  // Helper function to find special rates
  const findSpecialRate = (productId, qty) => {
    // In a real-world scenario, you might want to handle multiple matching rates (e.g., by date)
    return specialRates.find(
      (rate) =>
        rate.product_id === productId &&
        rate.status === "ACTIVE" &&
        qty >= (parseInt(rate.min_qty, 10) || 1)
    );
  };

  // Helper function to find flat rates
  const findFlatRate = (productId, qty) => {
    return flatRates.find(
      (rate) =>
        rate.product_id === productId &&
        rate.status === "ACTIVE" &&
        qty >= (parseInt(rate.min_qty, 10) || 1)
    );
  };

  let subtotal = 0;
  let finalTotal = 0;

  for (const item of cartItems) {
    const orderQty = parseInt(item.order_qty, 10) || 0;
    if (orderQty === 0) continue;

    const regularTp = parseFloat(item.tp) || 0.0;
    const vat = parseFloat(item.vat) || 0.0;
    const regularPricePerUnit = regularTp + vat;

    subtotal += orderQty * regularPricePerUnit;

    // Check for promotions, prioritizing special rates over flat rates.
    const special = findSpecialRate(item.item_id, orderQty);
    const flat = findFlatRate(item.item_id, orderQty);

    if (special) {
      const specialTp = parseFloat(special.tp) || regularTp;
      const specialVat = parseFloat(special.vat) || vat;
      finalTotal += orderQty * (specialTp + specialVat);
    } else if (flat) {
      // const minQty = parseInt(flat.min_qty, 10) || 1;
      const flatTotal = parseFloat(flat.total) || 0.0;
      // const bundleCount = Math.floor(orderQty / minQty);
      // const remainder = orderQty % minQty;

      finalTotal += orderQty * flatTotal;
    } else {
      // No promotion, use regular price
      finalTotal += orderQty * regularPricePerUnit;
    }
  }

  const totalDiscount = subtotal - finalTotal;

  // Return the result as a JSON string so Dart can easily parse it.
  return JSON.stringify({ subtotal, totalDiscount, grandTotal: finalTotal });
})();