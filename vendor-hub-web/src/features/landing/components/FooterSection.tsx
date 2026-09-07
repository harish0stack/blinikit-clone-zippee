import React from "react";

export const FooterSection: React.FC = () => {
  const companyLinks = ["About", "Careers", "Blog", "Press", "Lead", "Values"];
  const consumerLinks = ["Privacy", "Terms", "FAQs", "Security", "Mobile", "Contact"];
  const partnerLinks = ["Express", "Seller", "Warehouse", "Deliver", "Partner"];

  const socialIcons = [
    { name: "Facebook", icon: "/assets/landing/icon-facebook.svg", href: "#" },
    { name: "Twitter", icon: "/assets/landing/icon-twitter.svg", href: "#" },
    { name: "Instagram", icon: "/assets/landing/icon-instagram.svg", href: "#" },
    { name: "LinkedIn", icon: "/assets/landing/icon-linkedin.svg", href: "#" },
  ];

  return (
    <footer className="relative w-full bg-[#FCFCFC] pt-12 pb-36 sm:pb-48 md:pb-60 lg:pb-72 overflow-hidden">
      <div className="relative z-10 max-w-[1000px] mx-auto px-6">
        {/* Informational SEO blocks */}
        <div className="space-y-6 mb-10">
          <div>
            <h4 className="text-[14px] leading-[150%] font-medium text-[#1F1F1F] mb-1.5">
              #1 Instant delivery service in India
            </h4>
            <p className="text-[14px] leading-[150%] text-[#666666]">
              Shop on the go and get anything delivered to your doorstep. Buy everything from
              groceries to fresh fruits & vegetables, cakes and bakery items, meats & seafood,
              cosmetics, mobiles & accessories, electronics, baby care products and much more. We
              get it delivered to your doorstep in the safest way possible.
            </p>
          </div>

          <div>
            <h4 className="text-[14px] leading-[150%] font-medium text-[#1F1F1F] mb-1.5">
              Single app for all your daily needs
            </h4>
            <p className="text-[14px] leading-[150%] text-[#666666]">
              Order thousands of products at just a tap - milk, eggs, bread, cooking oil, ghee, atta,
              rice, fresh fruits & vegetables, spices, chocolates, chips, biscuits, Maggi, cold
              drinks, shampoos, soaps, body wash, pet food, diapers, electronics, other organic and
              gourmet products from your neighbourhood stores and a lot more.
            </p>
          </div>

          <div>
            <h4 className="text-[14px] leading-[150%] font-medium text-[#1F1F1F] mb-1.5">
              Order online on Blinkit to enjoy instant delivery magic
            </h4>
            <p className="text-[14px] leading-[150%] text-[#666666]">
              Cities we currently serve: Delhi, Gurugram, Kolkata, Lucknow, Mumbai, Bengaluru,
              Ahmedabad, Noida, Ghaziabad, Faridabad, Hyderabad, Jaipur, Pune, Chennai, Chandigarh,
              Ludhiana, Vadodara, Meerut, Kanpur, Panchkula, Kharar, Amritsar, Bhopal, Indore,
              Zirakpur, Jalandhar, Dehradun, Agra, Mohali, Goa, Patiala, Sonipat, Bhiwadi, Kota,
              Rohtak, Bahadurgarh, Haridwar, Bathinda, Kochi, Jodhpur and Jammu.
            </p>
          </div>
        </div>

        {/* Directory Links & Social Section */}
        <div className="border-t border-[#E0E0E0] pt-8 pb-10 flex flex-col md:flex-row justify-between gap-8">
          {/* Link Columns */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-8 md:w-[65%]">
            {/* Company Links */}
            <div>
              <h5 className="text-[14px] leading-[150%] font-semibold text-[#1F1F1F] mb-3">
                Company
              </h5>
              <ul className="space-y-2">
                {companyLinks.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="text-[14px] leading-[150%] text-[#666666] hover:text-[#1F1F1F] transition-colors"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>

            {/* Consumer Links */}
            <div>
              <h5 className="text-[14px] leading-[150%] font-semibold text-[#1F1F1F] mb-3">
                For Consumers
              </h5>
              <ul className="space-y-2">
                {consumerLinks.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="text-[14px] leading-[150%] text-[#666666] hover:text-[#1F1F1F] transition-colors"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>

            {/* Partner Links */}
            <div>
              <h5 className="text-[14px] leading-[150%] font-semibold text-[#1F1F1F] mb-3">
                For Partners
              </h5>
              <ul className="space-y-2">
                {partnerLinks.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="text-[14px] leading-[150%] text-[#666666] hover:text-[#1F1F1F] transition-colors"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Social Icons Column */}
          <div className="md:border-l md:border-[#E0E0E0] md:pl-10 flex flex-col items-start md:items-center">
            <h5 className="text-[14px] leading-[150%] font-semibold text-[#1F1F1F] mb-3">
              Follow us
            </h5>
            <div className="grid grid-cols-2 gap-3.5">
              {socialIcons.map((item) => (
                <a
                  key={item.name}
                  href={item.href}
                  className="w-8 h-8 flex items-center justify-center rounded-md hover:bg-black/5 transition-transform hover:scale-110 active:scale-95"
                  aria-label={item.name}
                >
                  <img src={item.icon} alt={item.name} className="w-8 h-8 object-contain" />
                </a>
              ))}
            </div>
          </div>
        </div>

        {/* Legal Disclaimer */}
        <div className="border-t border-[#E0E0E0] pt-6">
          <p className="text-[12px] leading-[150%] text-[#999999]">
            By continuing past this page you agree to our Terms, Cookie policy and Privacy policy. All
            trademarks are properties of their respective owners. © Blink Commerce Private Limited
            (formerly known as Grofers India Private Limited), 2016-2026
          </p>
        </div>
      </div>

      {/* Absolute Positioned Watermark Typography with more visible height */}
      <div
        className="absolute left-1/2 -translate-x-1/2 -bottom-10 sm:-bottom-16 md:-bottom-24 lg:-bottom-28 flex justify-center items-center pointer-events-none select-none z-0 w-full"
        aria-hidden="true"
      >
        <div className="flex font-bold text-[140px] sm:text-[220px] md:text-[300px] lg:text-[382px] leading-none tracking-tight">
          <span className="text-[#3E3A39]/15">B</span>
          <span className="text-[#3E3A39]/15">l</span>
          <span className="text-[#3E3A39]/15">i</span>
          <span className="text-[#3E3A39]/15">n</span>
          <span className="text-[#3E3A39]/15">k</span>
          <span className="text-[#318616]/60">i</span>
          <span className="text-[#318616]/60">t</span>
        </div>
      </div>
    </footer>
  );
};

