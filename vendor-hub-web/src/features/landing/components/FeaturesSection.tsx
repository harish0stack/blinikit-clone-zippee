import React from "react";

interface FeatureCardProps {
  title: string;
  description: string;
  bgImage: string;
}

const FeatureCard: React.FC<FeatureCardProps> = ({ title, description, bgImage }) => {
  return (
    <div className="h-[325.22px] min-h-[325.22px] max-w-[488px] w-full flex flex-col py-11 px-8 rounded-3xl overflow-clip relative bg-[#EBFFEF] border border-solid border-[#A3F0B580] mx-auto transition-transform duration-200 hover:-translate-y-0.5">
      {/* Background illustration */}
      <div
        className="h-[323.219px] w-full absolute bg-cover bg-position-[50%] inset-0 pointer-events-none"
        style={{ backgroundImage: `url('${bgImage}')` }}
      />

      {/* Card Content */}
      <div className="relative z-10 w-full">
        <h3 className="text-[32px] leading-[110%] font-extrabold text-[#1F1F1F] tracking-normal">
          {title}
        </h3>
        <div className="mt-4 pr-12 md:pr-24">
          <p className="text-[20px] leading-[130%] font-normal text-[#1F1F1F]">
            {description}
          </p>
        </div>
      </div>
    </div>
  );
};

export const FeaturesSection: React.FC = () => {
  const cards = [
    {
      title: "Reach your customers where they are",
      description: "We deliver your product through our dense network of 2000+ dark stores",
      bgImage: "/assets/landing/card-reach.webp",
    },
    {
      title: "Exponential growth opportunity",
      description: "List your products on India's fastest-growing retail channel and grow with us",
      bgImage: "/assets/landing/card-growth.webp",
    },
    {
      title: "Expand your reach",
      description: "Your products can now reach millions of customers in 100+ major cities",
      bgImage: "/assets/landing/card-network.webp",
    },
    {
      title: "It's simple and easy",
      description: "Onboard your products in minutes and manage your business effortlessly",
      bgImage: "/assets/landing/card-easy.webp",
    },
  ];

  return (
    <section className="w-full bg-white flex flex-col items-center">
      <div className="w-full max-w-[1410px] mx-auto px-4 md:px-6">
        {/* Header with decorative illustrations */}
        <div className="items-center flex justify-between mb-2.5 mt-[5%] p-2.5 w-full max-w-[1253px] mx-auto">
          {/* Left illustration */}
          <div className="hidden lg:block pl-[2%] shrink-0">
            <div
              className="aspect-[71/101] w-[142px] h-[202px] max-w-full overflow-clip bg-size-[100%_100%] bg-position-[50%] bg-no-repeat"
              style={{ backgroundImage: "url('/assets/landing/shelves.webp')" }}
            />
          </div>

          {/* Title in center */}
          <div className="flex flex-col px-[3%] text-center items-center mx-auto">
            <h2 className="tracking-[-2px] font-extrabold text-[#1F1F1F] text-3xl sm:text-4xl lg:text-[52px] leading-[1.15]">
              Why Blinkit is every
            </h2>
            <div
              className="bg-size-[200px_63px] bg-position-[100%] bg-no-repeat inline-block"
              style={{
                backgroundImage: "url('/assets/landing/highlight-badge.webp')",
              }}
            >
              <span className="tracking-[-2px] font-extrabold text-[#1F1F1F] text-3xl sm:text-4xl lg:text-[52px] leading-[1.15]">
                seller’s top choice?
              </span>
            </div>
          </div>

          {/* Right illustration */}
          <div className="hidden lg:flex items-end h-[116px] justify-end shrink-0">
            <div
              className="aspect-[91/58] w-[182px] h-[116px] max-w-full overflow-clip shrink-0 bg-size-[100%_100%] bg-position-[50%] bg-no-repeat"
              style={{ backgroundImage: "url('/assets/landing/people-moving.webp')" }}
            />
          </div>
        </div>

        {/* 2x2 Feature Cards Grid matching Paper specs */}
        <div className="grid grid-cols-1 md:grid-cols-2 mb-[5%] mt-[5%] px-4 sm:px-8 lg:px-[14%] gap-10 self-stretch">
          {cards.map((card) => (
            <FeatureCard
              key={card.title}
              title={card.title}
              description={card.description}
              bgImage={card.bgImage}
            />
          ))}
        </div>
      </div>
    </section>
  );
};
